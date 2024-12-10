# Description: script to validate ingested data, takes (--catalog: catalog name), (--batch: batch_id of the job),
#              (--configs_location: table meta data json file location on S3)
# Author: Lotfy Ashmawy

import os
os.environ["SPARK_VERSION"] = '3.3'
from utils.logger import Logger
from utils.ReaderWriter import ReadWriteHandler 
from utils.validate import ValidationHandler 
from utils.spark_session import SparkSessionStarter
from utils.schema import SchemaHandler
from pyspark.sql.functions import *




class ValidationRunner:
    def __init__(self, catalog, batch, table_configs):
        self.logger = Logger(self.__class__.__name__)
        self.spark = SparkSessionStarter(self.__class__.__name__).start_session()
        self.rw = ReadWriteHandler(catalog=catalog)
        self.vt = ValidationHandler()
        self.scm = SchemaHandler()
        self.catalog = catalog
        self.raw_table = table_configs["iceberg_raw_table"]
        self.val_table = table_configs["iceberg_validated_table"]
        self.merging_cols = table_configs["id_cols"]
        self.batch_id = batch
        self.dq_checks = table_configs["quality_checks"]
        self.dq_url = "{}/{}/{}/{}/{}/{}".format(
            table_configs["DQ_output_location"],
            self.val_table.split(".")[-1],
            "year="+str(batch)[0:4], 
            "month="+str(batch)[4:6], 
            "day="+str(batch)[6:8],
            "hour="+str(batch)[8::]
            )
        
        
    def run(self) -> None:
        # read data from source location
        df = self.rw.read_iceberg(table=self.raw_table, _filter=f"batch_id={self.batch_id}")
        
        # compare source and target schemas and apply changes if existed
        self.scm.iceberg_schema_change(df=df, table=f"{self.catalog}.{self.val_table}")
        
        # prepare target table and spark session for WAP 
        _branch = "B_"+str(self.batch_id)
        
        self.spark.conf.set("spark.wap.branch", _branch)
        self.spark.sql(f"ALTER TABLE {self.catalog}.{self.val_table} SET TBLPROPERTIES ('write.wap.enabled'='true')")
        self.spark.sql(f"ALTER TABLE {self.catalog}.{self.val_table} DROP BRANCH IF EXISTS {_branch}")
        self.spark.sql(f"ALTER TABLE {self.catalog}.{self.val_table} CREATE BRANCH {_branch}")
        
        self.logger.info(f"Table {self.val_table} is ready for Write-Audit-Publish")
        
        
        # Write data to branch
        self.rw.upsert_iceberg(table=self.val_table, df=df, merging_columns=self.merging_cols)

        # read from branch
        df_branch = self.rw.read_iceberg(table=self.val_table, branch=_branch)
        
        # run quality checks
        check_results_df = self.vt.quality_checks(df=df_branch, checks=self.dq_checks, output_url=self.dq_url)
        
        # check for failed error checks and puplish branch 
        _failed_error_checks = check_results_df.filter((col("check_level") == "error") & (col("check_status") == "error"))

        if _failed_error_checks.count() == 0:
            self.spark.sql(
                f"CALL {self.catalog}.system.fast_forward(table => '{self.catalog}.{self.val_table}', branch => 'main', to => '{_branch}')"
                     )
            self.logger.info("Data had met quality constraints and published to production")

        else:
            self.spark.sql(f"ALTER TABLE {self.catalog}.{self.val_table} DROP BRANCH IF EXISTS {_branch}")
            self.logger.info("Data quality failed and branch was droped ")
            check_results_df.show()



        self.spark.sql(f"ALTER TABLE {self.catalog}.{self.val_table} UNSET TBLPROPERTIES ('write.wap.enabled')")
        
        if self.spark:
            self.spark.stop()
        

if __name__=="__main__":
    ValidationRunner().run()