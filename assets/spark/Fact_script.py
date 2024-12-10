# Description: Run fact batch job, takes (--catalog: catalog name), (--batch: batch_id of the job),
#              (--configs_location: Fact meta data json file location on S3)
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



class FactRunner:
    def __init__(self, catalog:str, batch:int, fact_configs:dict):
        self.logger = Logger(self.__class__.__name__)
        self.spark = SparkSessionStarter(self.__class__.__name__).start_session()
        self.rw = ReadWriteHandler(catalog=catalog)
        self.val = ValidationHandler()
        self.scm = SchemaHandler()
        self.trn = TransformHandler()
        self.catalog = catalog
        self.fact_table = fact_configs["fact_table"]
        self.source_tables= fact_configs["source_tables"]
        self.surrogate_key = fact_configs["surrogate_key"]
        self.natural_keys = fact_configs["natural_keys"]
        self.joins = fact_configs["joins"]
        self.columns = fact_configs["columns"]
        self.filter = None if fact_configs["filter"] == "none" else fact_configs["filter"]
        self.batch = batch
        self.DQ_checks = fact_configs["quality_checks"]
        self.DQ_URL = "{}/{}/{}/{}/{}/{}".format(
            fact_configs["DQ_output_URL"],
            self.fact_table.split(".")[-1],
            "year="+str(batch)[0:4], 
            "month="+str(batch)[4:6], 
            "day="+str(batch)[6:8],
            "hour="+str(batch)[8::]
        )
        
    def run(self) -> None:
        
        # read all source tables
        source_dfs = {}
        for table in self.source_tables:
            source_dfs[table] = self.rw.read_iceberg(table=table)
        
        # join all source tables
        joined_df = self.trn.join(dfs=source_dfs, joins=self.joins, columns=self.columns, _filter=self.filter)
        
        # get last surrogate key for the fact table
        last_key = self.rw.read_iceberg(table=self.fact_table).agg(max(self.surrogate_key)).collect()[0][0]
        
        # genrate surrogate key
        sk_df = self.trn.genrate_fact_surrogete_key(data=joined_df, sk_name=self.surrogate_key, last_key=last_key)
        
        # modify schema to match target schema
        source_df = self.scm.modify_schema(df=sk_df, table=f"{self.catalog}.{self.fact_table}")
        
        # prepare target table and spark session for WAP
        _branch = "B_"+str(self.batch)
        
        self.spark.conf.set("spark.wap.branch", _branch)
        self.spark.sql(f"ALTER TABLE {self.catalog}.{self.fact_table} SET TBLPROPERTIES ('write.wap.enabled'='true')")
        self.spark.sql(f"ALTER TABLE {self.catalog}.{self.fact_table} DROP BRANCH IF EXISTS {_branch}")
        self.spark.sql(f"ALTER TABLE {self.catalog}.{self.fact_table} CREATE BRANCH {_branch}")
        
        self.logger.info(f"Table {self.catalog}.{self.fact_table} ready for Write-Audit-Publish")
        
        # write to branch
        self.rw.upsert_iceberg(table=self.fact_table, df=source_df, merging_columns=self.natural_keys)
        
        # read from branch
        df_branch = self.rw.read_iceberg(table=self.fact_table, branch=_branch)
        
        # run quality checks
        check_results_df = self.val.quality_checks(df=df_branch, checks=self.DQ_checks, output_url=self.DQ_URL)

        # check for faild error checks and puplish to production
        _failed_error_checks = check_results_df.filter((col("check_level") == "error") & (col("check_status") == "error"))
        
        if _failed_error_checks.count() == 0:
            self.spark.sql(
                f"CALL {self.catalog}.system.fast_forward(table => '{self.catalog}.{self.fact_table}', branch => 'main', to => '{_branch}')"
                     )
            self.logger.info("Data had met quality constraints and published to production")

        else:
            self.spark.sql(f"ALTER TABLE {self.catalog}.{self.fact_table} DROP BRANCH IF EXISTS {_branch}")
            self.logger.info("Data quality failed and branch was droped ")
            _failed_error_checks.show()
            

        self.spark.sql(f"ALTER TABLE {self.catalog}.{self.fact_table} UNSET TBLPROPERTIES ('write.wap.enabled')")
        
        if self.spark:
            self.spark.stop() 
            

if __name__=="__main__":
    FactRunner(catalog="glue_iceberg", batch=2024091822, fact_configs=fact).run()