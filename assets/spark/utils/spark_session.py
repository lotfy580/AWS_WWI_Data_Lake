from pyspark.sql import SparkSession
import os

class SparkSessionStarter:
    
    def __init__(self, app_name, configs=None):
        self.app_name = app_name
        self.configs = configs if configs else {}
    
    def start_session(self):
        
        if any("deequ" in config for config in self.configs.values()):
            os.environ["SPARK_VERSION"] = '3.3'
            
        spark = SparkSession.builder.appName(self.app_name).getOrCreate()
        
        for k, v in self.configs.items():
            spark.config(k, v)
            
        return spark