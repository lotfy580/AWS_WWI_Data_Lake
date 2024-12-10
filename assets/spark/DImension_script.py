# Description: Run dimension batch job, takes (--catalog: catalog name), (--configs_location: dimension meta data json file location on S3)
# Author: Lotfy Ashmawy

import os
os.environ["SPARK_VERSION"] = '3.3'
from utils.logger import Logger
from utils.ReaderWriter import ReadWriteHandler 
from utils.validate import ValidationHandler 
from utils.spark_session import SparkSessionStarter
from utils.schema import SchemaHandler
from utils.transform import TransformHandler
from pyspark.sql.functions import *




class DimensionRunner:
    def __init__(self, catalog, dim_configs:dict):
        self.logger = Logger(self.__class__.__name__)
        self.spark = SparkSessionStarter(self.__class__.__name__).start_session()
        self.rw = ReadWriteHandler(catalog=catalog)
        self.val = ValidationHandler()
        self.scm = SchemaHandler()
        self.trn = TransformHandler()
        self.catalog = catalog
        self.dimension_table = dim_configs["dimension_table"]
        self.source_tables = dim_configs["source_tables"]
        self.joins = dim_configs["joins"]
        self.filter = None if dim_configs["filter"] == "none" else dim_configs["filter"]
        self.surrogate_key = dim_configs["surrogate_key"]
        self.natural_keys = dim_configs["natural_keys"]
        self.columns = dim_configs["columns"]
        self.checks = dim_configs["quality_checks"]
        self.dq_url = dim_configs["DQ_output_URL"]
        self.scd1_cols = [col["name"] for col in self.columns if col["scd_type"] == "1"]
        self.scd2_cols = [col["name"] for col in self.columns if col["scd_type"] == "2"]
        self.scd1_cols = None if len(self.scd1_cols) == 0 else self.scd1_cols
        self.scd2_cols = None if len(self.scd2_cols) == 0 else self.scd2_cols
        
    def run(self) -> None:
        
        # read all source tables
        source_dfs={}
        for table in self.source_tables:
            source_dfs[table] = self.rw.read_iceberg(table=table)
            
        # join all source tables
        source_df = self.trn.join(dfs=source_dfs, joins=self.joins, columns=self.columns, _filter=self.filter)
        source_df=self.scm.modify_schema(df=source_df, table=f"{self.catalog}.{self.dimension_table}")
        
        # read target dimension table
        target_df = self.rw.read_iceberg(table=self.dimension_table).drop(self.surrogate_key)
        
        # compare source and target, and apply slowly_changing_dimension
        scd_df = self.trn.slowly_changing_dimension(
            source_df=source_df, 
            target_df=target_df, 
            join_key=self.natural_keys[0],
            scd_type1_cols=self.scd1_cols, 
            scd_type2_cols=self.scd2_cols
        )
        # generate surrogete key for dimension table
        sk_df = self.trn.genrate_dim_surrogete_key(data=scd_df, sk_name=self.surrogate_key, natural_keys=self.natural_keys)
        
        # modify source schema to match target schema 
        schema_modified_df=self.scm.modify_schema(df=sk_df, table=f"{self.catalog}.{self.dimension_table}")
        
        # run quality checks
        check_results_df = self.val.quality_checks(df=schema_modified_df, checks=self.checks, output_url=self.dq_url)
        
        # check for failed error checks and write data to production
        _failed_error_checks = check_results_df.filter((col("check_level") == "error") & (col("check_status") == "error"))
        
        if _failed_error_checks.count() == 0:
            self.rw.write_iceberg(table=self.dimension_table, df=schema_modified_df, mode="overwrite")
            self.logger.info("Data had met quality constraints and published to production")
        else:
            self.logger.error("Data quality failed")
            check_results_df.show()
            
        if self.spark:
            self.spark.stop()
        
        
if __name__=="__main__":
    DimensionRunner(catalog="glue_iceberg", dim_configs=dim).run()
        
        
        
        
        
            