# Description: script to ingest data from landing to raw zone, takes (--catalog: catalog name), (--batch: batch_id of the job),
#              (--configs_location: table meta data json file location on S3)
# Author: Lotfy Ashmawy

from utils.logger import Logger
from utils.ReaderWriter import ReadWriteHandler 
from utils.spark_session import SparkSessionStarter
from utils.schema import SchemaHandler
from pyspark.sql.functions import *

_dict = {
    "dimension_table": "wwi_dwh.dim_customer",
    "DQ_output_URL": "s3://devwwidatalakehouse/Deequ_checks/DWH/dim_customer",
    "surrogate_key": "customer_key",
    "natural_keys": ["customer_id"],
    "source_tables" : [
        "wwi_validated.customers", "wwi_validated.buying_groups", "wwi_validated.customer_categories", "wwi_validated.people"
    ],
    "joins": [
        {
            "with": "wwi_validated.buying_groups",
            "alias": "buying_groups",
            "join_condition":"customers.buying_group_id = buying_groups.buying_group_id",
            "broadcast":"false",
            "join_type": "left"
        },
        {
            "with": "wwi_validated.customers",
            "alias": "customers2",
            "join_condition":"customers.bill_to_customer_id = customers2.customer_id",
            "broadcast":"false",
            "join_type": "left"
        },
        {
            "with": "wwi_validated.people",
            "alias": "people",
            "join_condition":"customers.primary_contact_person_id = people.person_id",
            "broadcast":"false",
            "join_type": "left"
        },
        {
            "with": "wwi_validated.customer_categories",
            "alias": "customer_categories",
            "join_condition":"customers.customer_category_id = customer_categories.customer_category_id",
            "broadcast":"false",
            "join_type": "left"
        }
    ],
    "filter": "none",
    "columns": [
        {
            "name": "customer_id",
            "source": "customers.customer_id",
            "datatype": "int",
            "transform": "none",
            "scd_type": "0"
        },
        {
            "name": "customer",
            "source": "customers.customer_name",
            "datatype": "string",
            "transform": "none",
            "scd_type": "1"
        },
        {
            "name": "bill_to_customer",
            "source": "customers2.customer_name",
            "datatype": "string",
            "transform": "none",
            "scd_type": "2"
        },
        {
            "name": "category",
            "source": "customer_categories.customer_category_name",
            "datatype": "string",
            "transform": "none",
            "scd_type": "2"
        },
        {
            "name": "buying_group",
            "source": "buying_groups.buying_group_name",
            "datatype": "string",
            "transform": "none",
            "scd_type": "1"
        },
        {
            "name": "primary_contact",
            "source": "people.full_name",
            "datatype": "string",
            "transform": "none",
            "scd_type": "2"
        },
        {
            "name": "postal_code",
            "source": "customers.postal_postal_code",
            "datatype": "string",
            "transform": "none",
            "scd_type": "2"
        }
    ],
    "quality_checks": [
        {
            "column": "customer_id",
            "type": "is_complete",
            "assertion": "none",
            "status": "error"
        },
        {
            "column": "customer",
            "type": "is_name",
            "assertion": "none",
            "status": "warning"
        },
        {
            "column": "bill_to_customer",
            "type": "is_complete",
            "assertion": "none",
            "status": "error"
        },
        {
            "column": "category",
            "type": "is_name",
            "assertion": "none",
            "status": "warning"
        },
        {
            "column": "primary_contact",
            "type": "is_complete",
            "assertion": "none",
            "status": "error"
        },
        {
            "column": "primary_contact",
            "type": "is_name",
            "assertion": "none",
            "status": "warning"
        },
        {
            "column": "postal_code",
            "type": "has_max_length",
            "assertion": "lambda x: x==6",
            "status": "warning"
        }
    ]
    
}


# catalog = "glue_iceberg"
# iceberg_table = _dict["iceberg_raw_table"]
# trg_table = f"{catalog}.{iceberg_table}"
# data_local = _dict["data_location"]
# id_cols = _dict["id_cols"]
# col_mapping = _dict["columns_mapping"]
# batch_id = 2024091822


class IngestionRunner:
    def __init__(self, catalog, batch, table_configs):
        self.logger = Logger(self.__class__.__name__)
        self.spark  = SparkSessionStarter(self.__class__.__name__)
        self.rw     = ReadWriteHandler(catalog=catalog)
        self.scm    = SchemaHandler()
        self.catalog = catalog
        self.iceberg_table = table_configs["iceberg_raw_table"]
        self.data_location = table_configs["data_local"]
        self.id_cols = table_configs["id_cols"]
        self.col_mapping = table_configs["columns_mapping"]
        self.batch_id = batch
        
    def run(self) -> None:
        # get data url from batch_id
        data_url = f"{self.data_location}/{str(self.batch_id)[0:4]}/{str(self.batch_id)[4:6]}/{str(self.batch_id)[6:8]}/{str(self.batch_id)[8::]}/*"
        
        # read data from location
        df = self.rw.read_avro(location_url=data_url)
        
        if df:
            df_dd = df.dropDuplicates()
            # modify data with given schema
            df_schema = self.scm.modify_schema(df=df_dd, schema=self.col_mapping)
            df_batch = df_schema.withColumn("batch_id", lit(self.batch_id))
            
            # compare given schema with target table schema and apply changes if existed 
            self.scm.iceberg_schema_change(df=df_batch, table=f"{self.catalog}.{self.iceberg_table}")
            
            # write data to target
            self.rw.upsert_iceberg(table=self.iceberg_table, df=df_batch, merging_columns=self.id_cols)
            
if __name__=="__main__":
    IngestionRunner().run()