# Description: class to manage schema definetion and schema changes for spark applications
# Author: Lotfy Ashmawy

from utils.logger import Logger
from utils.spark_session import SparkSessionStarter
from utils.ReaderWriter import ReadWriteHandler 
from pyspark.sql import DataFrame
from pyspark.sql.functions import *
from pyspark.sql.types import *

class SchemaHandler:

    def __init__(self):
        self.logger = Logger(self.__class__.__name__)
        self.spark  = SparkSessionStarter(self.__class__.__name__).start_session()
        
    def spark_type(self, _type:str) -> DataType:
        """ 
        take iceberg syntax datatype and return same datatype in pyspark 

        Args:
            _type (str): imput datatype

        Returns:
            DataType: output datatype
        """
        _type = _type.lower()
        if _type == "int":
            return IntegerType()
        elif _type == "bigint":
            return LongType()
        elif _type == "string":
            return StringType()
        elif _type == "date":
            return DateType()
        elif _type == "timestamp":
            return TimestampType()
        elif _type == "boolean":
            return BooleanType()
        elif _type == "array":
            return ArrayType()
        elif _type == "binary":
            return BinaryType()
        elif _type == "long":
            return LongType()
        elif _type == "double":
            return DoubleType()
        elif "decimal" in _type:
            return eval(f"DecimalType{_type.split('l')[-1]}")
        else:
            return _type
    
    def modify_schema(self, df:DataFrame, table:str, columns_mapping:list=None) -> DataFrame:
        """ 
        modify schema of a dataframe based in given schema if exited,
        if not , it will compare the dataframe schema to target iceberg table schema
        and modfiy the dataframe to match target table.
        create new columns in target iceberg table if existed.

        Args:
            df (DataFrame): spark dataframe 
            table (str): target iceberg table name
            columns_mapping (list, optional): list of dicts each represent column name, datatype and nullabilty. Defaults to None.

        Returns:
            DataFrame: Dataframe thet match target table schema
        """
        ###############################################################################
        trg_df = self.spark.read.format("iceberg").table(table).filter("1=0")
        
        if columns_mapping:
            _fields = []
            _selects = []
            for _map in columns_mapping:
                src_name, trg_name, _type, _null = _map["source_column_name"], _map["target_column_name"], _map["data_type"], _map["nullable"]

                if _type == "timestamp" and df.select(src_name).dtypes[0][1] == "bigint":
                    if df.select(src_name).limit(1).collect()[0][0] >= 2534023008e8:
                        df = df.withColumn(src_name, lit("9999-12-31 23:59:59.9999999").cast("timestamp"))
                    else:
                        df = df.withColumn(src_name, from_unixtime((col(src_name)/1e6)).cast("timestamp"))

                elif _type == "date" and df.select(src_name).dtypes[0][1] == "int":
                    df = df.withColumn(src_name, expr(f"date_add('1970-01-01', {src_name})"))

                elif _type == "boolean" and any(typ in df.select(src_name).dtypes[0][1] for typ in ["int", "decimal"]):
                    df = df.withColumn(src_name, when(col(src_name) == 1, lit(True)).otherwise(lit(False)))

                _fields.append(StructField(src_name, self.spark_type(_type), False if _null == "false" else True))
                _selects.append(col(src_name).cast(_type).alias(trg_name))
                
                df = self.spark.createDataFrame(df.rdd, schema=StructType(_fields))
        else:
            _fields=[]
            for field in df.schema:
                if field.name in trg_df.columns:
                    _fields.append(StructField(field.name, trg_df.schema[field.name].dataType, trg_df.schema[field.name].nullable))
                else:
                    _fields.append(StructField(field.name, field.dataType, field.nullable))
                    
            df = self.spark.createDataFrame(df.rdd, schema=StructType(_fields))
                
        
        counter=0
        for col in df.columns:
            if col not in trg_df.columns:
                self.spark.sql(f"ALTER TABLE {table} ADD COLUMNS ({col} {df.select(col).dtypes[0][1]})")
                self.logger.info(f"New Column {col} added to {table}")
        if counter>=2:
            self.logger.warning(f"Many columns identified as new columns and added to {table}")
        return df
    
    
    def iceberg_schema_change(self, df:DataFrame, table:str) -> None:
        """
        compare columns of a given dataframe to target iceberg table and create new columns if existed.

        Args:
            df (DataFrame): given dataframe
            table (str): target iceberg table
        """
        target_columns = self.spark.read.format("iceberg").table(table).filter("1=0").columns
        
        counter=0
        for col in df.columns:
            if col not in target_columns:
                self.spark.sql(f"ALTER TABLE {table} ADD COLUMNS ({col} {df.select(col).dtypes[0][1]})")
                self.logger.info(f"New Column {col} added to {table}")
                counter+=1
                
        if counter==0:
            self.logger.info(f"No new columns dedected for table {table}")
        elif counter>=2:
            self.logger.warning(f"Many columns identified as new columns and added to {table}")