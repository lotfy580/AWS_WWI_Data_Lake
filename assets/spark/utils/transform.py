# Description: class for all transformations for spark applications
# Author: Lotfy Ashmawy

from utils.logger import Logger
from utils.spark_session import SparkSessionStarter 
from utils.ReaderWriter import ReadWriteHandler
from pyspark.sql.functions import *

class TransformHandler:
    
    def __init__(self):
        self.logger = Logger(self.__class__.__name__)
        self.spark  = SparkSessionStarter(self.__class__.__name__).start_session()
        
    def join(self, dfs:dict, joins:list, columns:list=None, _filter:str=None) -> DataFrame:
        """ 
        join given dataframes in one DataFrame 

        Args:
            dfs (dict): input Spark DataFrame in dict -> {DataFrame_Name: DataFrame (Spark DataFrame)}
            joins (list): list of dicts each repersent join configration -> {
                "with": "Dataframe name to join with from input dfs",
                "alias": "name to alias the dataframe",
                "broadcast": "true to preform broadcast join else false",
                "join_condition": "joining condition in spark SQL synatx",
                "join_type": "type of join: left, right, inner...etc"
            }
            columns (list, optional): list of columns selected for the joined DataFrame. Defaults to None.
            _filter (str, optional): Filter condition in pyspark syntax will applied after joining. Defaults to None.

        Returns:
            DataFrame: joined DataFrame in spark DataFrame
        """

        df = next(iter(dfs.values()), None)
        if len(dfs) > 1:
            for join in joins:
                join_with_df = dfs[join["with"]].alias(join["alias"])
                df = df.join(
                    broadcast(join_with_df) if join["broadcast"] == "true" else join_with_df, 
                    on=expr(join["join_condition"]), 
                    how=join["join_type"]
                )
        else:
            self.logger.error("Input DataFrames must be more than 1!")

        if columns:
            selects=[]
            for column in columns:
                if column["transform"] == "none":
                    selects.append(col(column["source"]).alias(column["name"]))

                elif column["transform"] =="surrogate_key":
                    continue
                else:
                    selects.append(eval(column["transform"]).alias(column["name"]))

            df = df.select(*selects)

        if _filter:
            df = df.filter(_filter)

        return df
    
    
    def apply_scd_hash_expr(
        self,
        source_df:DataFrame, 
        target_df:DataFrame, 
        scd_type1_cols:list=None, 
        scd_type2_cols:list=None
        ) -> [DataFrame, DataFrame]: # type: ignore
        """ 
        concatenate all slowly changing dimension type 1 and type 2 columns then apply hash 
        and store them in a new columns scd_1, scd_2 

        Args:
            source_df (DataFrame): new data of the dimenstion table
            target_df (DataFrame): current data of the dimention table
            scd_type1_cols (list, optional): list of column with type 1 slowley changing dimension. Defaults to None.
            scd_type2_cols (list, optional): list of column with type 1 slowley changing dimension. Defaults to None.

        Returns:
            [DataFrame, DataFrame]: new DataFrames with hash columns
        """
        if scd_type1_cols:
            scd_type1_hash_expr = md5(concat_ws("|", *[col(column) for column in scd_type1_cols]))
            source_df = source_df.withColumn("scd_1", scd_type1_hash_expr)
            target_df = target_df.withColumn("scd_1", scd_type1_hash_expr)
            
        if scd_type2_cols:
            scd_type2_hash_expr = md5(concat_ws("|", *[col(column) for column in scd_type2_cols]))
            source_df = source_df.withColumn("scd_2", scd_type2_hash_expr)
            target_df = target_df.withColumn("scd_2", scd_type2_hash_expr)
            
        return source_df.alias("source"), target_df.alias("target")
    
    
    def slowly_changing_dimension(
        self,
        source_df:DataFrame, 
        target_df:DataFrame,
        join_key:str,
        scd_type1_cols:list=None, 
        scd_type2_cols:list=None
        ) -> DataFrame:
        """
        compare source and target DataFrames and apply slowly changing dimension

        Args:
            source_df (DataFrame): new dimension data
            target_df (DataFrame): current dimension data
            join_key (str): natural key of the dimension table
            scd_type1_cols (list): list of scd type 1 columns
            scd_type2_cols (list): list of scd type 2 columns

        Returns:
            DataFrame: dimension data 
        """
        
        
        source, target = self.apply_scd_hash_expr(source_df, target_df, scd_type1_cols, scd_type2_cols)

        new_records = (
            source.join(target, col(f"source.{join_key}") == col(f"target.{join_key}"), "left_anti")
            .select("source.*")
            .withColumn("start_date", current_date())
            .withColumn("end_date", lit(None))
            .withColumn("is_current", lit(True))
        )
        insert_from_source = new_records

        all_records = target.join(source, col(f"target.{join_key}") == col(f"source.{join_key}"), "left")

        unchanged_records = (
            all_records
            .filter(
                f"""            
                {"source.scd_1 = target.scd_1" if scd_type1_cols else "1=1"} AND 
                {"source.scd_2 = target.scd_2" if scd_type2_cols else "1=1"}
                """
            )
            .select("target.*")
        )
        insert_from_target = unchanged_records

        if scd_type2_cols:
            scd2_records = (
                all_records
                .filter(
                    col(f"source.{join_key}").isNotNull() &
                    (col("source.scd_2") != col("target.scd_2")))
            )

            scd2_updated_records = (
                scd2_records
                .select("source.*")
                .withColumn("start_date", current_date())
                .withColumn("end_date", lit(None))
                .withColumn("is_current", lit(True))
                )
            insert_from_source = insert_from_source.unionByName(scd2_updated_records)

            scd2_historical_records = (
                scd2_records
                .select("target.*")
                .withColumn("end_date", current_date())
                .withColumn("is_current", lit(False))
            )
            insert_from_target = insert_from_target.unionByName(scd2_historical_records)

        if scd_type1_cols:
                scd1_records = (
                    all_records
                    .filter(
                        f"""
                        source.{join_key} IS NOT NULL AND 
                        source.scd_1 != target.scd_1 AND 
                        {"source.scd_2 = target.scd_2" if scd_type2_cols else "1=1"}
                        """
                    )
                    .select("source.*", "target.start_date", "target.end_date", "target.is_current")
                )
                insert_from_source = insert_from_source.unionByName(scd1_records)

        final_data = insert_from_source.unionByName(insert_from_target)


        return final_data.select(*[col(c) for c in target_df.columns])
    
    def genrate_dim_surrogete_key(self, data:DataFrame, sk_name:str, natural_keys:list) -> DataFrame:
        """ 
        genrate surrogete key for a dimension with compination of natural key (int) for current data
        and negative auto increament for historical data 

        Args:
            data (DataFrame): dimension DataFrame
            sk_name (str): name of the surrogate key column
            natural_keys (list): list of natural key columns (must be intgers)

        Returns:
            DataFrame: dimension DataFrame with genrated surrogate key
        """
        current_data = data.filter(col("is_current") == True)
        current_sk_expr = concat(*[col(column).cast("string") for column in natural_keys])
        sk_current_data = current_data.withColumn(sk_name, current_sk_expr.cast("int"))

        historical_data = data.filter(col("is_current") == False)
        sk_historical_data = historical_data.withColumn(sk_name, -(monotonically_increasing_id()+1))

        final_data = sk_current_data.unionByName(sk_historical_data)
        return final_data
    
    def genrate_fact_surrogete_key(self, data:DataFrame, sk_name:str, last_key:int) -> DataFrame:
        """
        genrate surrogete key for fact table by auto increament start after the last key

        Args:
            data (DataFrame): fact data
            sk_name (str): name of the surrogate key column
            last_key (int): last surrogate key generated from previous jobs

        Returns:
            DataFrame: fact data with surrogete key
        """
        if last_key is None:
            last_key = 1
        
        return data.withColumn(sk_name, monotonically_increasing_id()+last_key)