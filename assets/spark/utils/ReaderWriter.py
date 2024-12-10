# Description: class to manage reading and writing data for spark applications
# Author: Lotfy Ashmawy

from utils.logger import Logger
from utils.spark_session import SparkSessionStarter
from pyspark.sql import DataFrame
from pyspark.sql.functions import col

class ReadWriteHandler:
    def __init__(self, catalog=None):
        self.logger = Logger(self.__class__.__name__)
        self.spark = SparkSessionStarter(self.__class__.__name__).start_session()
        self.catalog = catalog if catalog else ""
        self.catalogdot = f"{catalog}." if catalog else ""
        
    def read_avro(self, location_url:str, _filter:str=None) -> DataFrame:
        """
        Read Avro formated data from given S3 location 

        Args:
            location_url (str): s3 location url
            _filter (str, optional): filter condition to the data. Defaults to None.

        Returns:
            DataFrame: spark DataFrame
        """

        try:
            df = (
                self.spark.read.format("avro")
                .load(location_url)
            )
            if _filter:
                df = df.filter(_filter)
            count = df.count()
            self.logger.info(f"{location_url} loaded, {count} rows")
            return df
        except Exception as e:
            if "Path does not exist" in str(e):
                self.logger.info(f"No data found in {location_url}")
            else:
                self.logger.error(f"Loading data failed due to {e}")
            return None
        
    def read_iceberg(self, table:str, branch:str=None, _filter:str=None) -> DataFrame:
        # takes source table name: str, batch_id: int
        # creates temp view for target table
        # returns temp view name if data was found else return None
        """
        Read data from iceberg table and return it to spark DataFrame.
        if branch name is given it will read data of this branch else it read main branch
        if filter is given, it will filter data based in given condition in spark SQL syntax 

        Args:
            table (str): iceberg table 
            branch (str, optional): branch name. Defaults to None.
            _filter (str, optional): filter condition in spark SQL syntax. Defaults to None.

        Returns:
            DataFrame: spark DataFrame
        """
        self.logger.info(f"Loading data from {table}")
        try:
            _df = (            
                self.spark.read
                .format("iceberg")
                .option("BRANCH", branch if branch else "main")
                .table(f"{self.catalogdot}{table}")
                )
            
            if _filter:
                _df = _df.filter(_filter)
            
            _count=_df.count()

            if _count == 0:
                self.logger.info(f"No data found table {table}")
            else:
                self.logger.info("Data loaded, {} rows".format(_count))
            return _df
        except Exception as _e:
            self.logger.error(f"Loading data from table {table} failed due to {_e}")
            return None
        
    def write_iceberg(self, table:str, df:DataFrame, mode:str=None) -> None:
        """
        Write a given dataframe to a given iceberg table.

        Args:
            table (str): Iceberg table name
            df (DataFrame): given Dataframe
            mode (str, optional): write mode. Defaults to append.
        """
        mode_op = mode if mode else "append"
        
        df.write.format("iceberg").mode(mode_op).save(f"{self.catalogdot}{table}")
        
        
        
    def upsert_iceberg(self, table:str, df:DataFrame, merging_columns) -> None:
        """
        upsert given dataframe to given iceberg table.
        

        Args:
            table (str): Iceberg table name
            df (DataFrame): given Dataframe
            merging_columns (list or str): primary key/s used for merging two datasets. 
        """
        # Set the merging condition
        if type(merging_columns) == list:
            merging_cond=" AND ".join([f"src.{col} = trg.{col}" for col in merging_columns])
        else:
            merging_cond = merging_columns
        _temv = "staging"
        df.createOrReplaceTempView(_temv)

        query = f"""
        MERGE INTO {self.catalogdot}{table} trg
        USING (SELECT * FROM {_temv}) src
        ON {merging_cond}
        WHEN MATCHED THEN 
        UPDATE SET *

        WHEN NOT MATCHED THEN 
        INSERT *;
        """

        self.spark.sql(query)
        self.logger.info(f"Upserting to {table} succeded!")