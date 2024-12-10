# Description: class for validating data 
# Author: Lotfy Ashmawy

import pydeequ
from pydeequ.checks import *
from pydeequ.verification import *
from pydeequ.analyzers import *
from pyspark.sql.functions import *
from pyspark.sql.dataframe import DataFrame
from utils.logger import Logger
from utils.spark_session import SparkSessionStarter

class ValidationHandler:
    
    def __init__(self):
        self.logger = Logger(self.__class__.__name__)
        self.spark  = SparkSessionStarter(self.__class__.__name__).start_session()
    
    
    def create_check(self, check:dict):
        """ 
        Takes an input check properties and return Deequ check

        Args:
            check (dict): check properties -> {
                column: column Name, 
                type: check type, 
                assertion: check assertion if existed, else none,
                status: status of check (error, warning) 
                }

        Returns:
            _check: Deequ check
            _column: column name
            _type_: type of the check
            _assertion: assertion of the check
        """
        _column = check["column"]
        _type_ = check["type"]
        _assertion = eval(check["assertion"]) if check["assertion"] and "lambda" in check["assertion"] else check["assertion"]
        _status = check["status"]
        _check = Check(
            self.spark, 
            CheckLevel.Error if _status == "error" else CheckLevel.Warning, 
            f"{_column}_{_type_}")
        return _check, _column, _type_, _assertion
    
    def quality_checks(self, df: DataFrame, checks:list, output_url:str):
        """
        Apply Deequ quality checks for given spark dataframe and output check results to s3 location 

        Args:
            df (Spark DataFrame): DataFrame which will be checked
            checks (list): list of dictionaries each represent a check properties 
            output_url (str): S3 location which check results will be stored in json format

        Returns:
            _check_results_df: check result in Spark DataFrame
        """

        _check_results = VerificationSuite(self.spark).onData(df)

        for check_prps in checks:

            _check, _column, _type, _assertion = self.create_check(check_prps)


            try:
                if _type == "is_complete":

                    _check_results.addCheck(_check.isComplete(_column))

                elif _type == "is_unique":

                    _check_results.addCheck(_check.isUnique(_column))

                elif _type == "has_size":

                    _check_results.addCheck(_check.hasSize(_column, _assertion))  

                elif _type == "has_min":


                    _check_results.addCheck(_check.hasMin(_column, _assertion))

                elif _type == "has_max":


                    _check_results.addCheck(_check.hasMax(_column, _assertion))

                elif _type == "has_sum":


                    _check_results.addCheck(_check.hasSum(_column, _assertion))  

                elif _type == "has_max_length":


                    _check_results.addCheck(_check.hasMaxLength(_column, _assertion))

                elif _type == "has_min_length":


                    _check_results.addCheck(_check.hasMinLength(_column, _assertion))

                elif _type == "has_mean":


                    _check_results.addCheck(_check.hasMean(_column, _assertion))

                elif _type == "has_standard_deviation":


                    _check_results.addCheck(_check.hasStandardDeviation(_column, _assertion)) 

                elif _type == "is_contained_in":


                    _check_results.addCheck(_check.isContainedIn(_column, _assertion))

                elif _type == "is_non_negative":

                    _check_results.addCheck(_check.isNonNegative(_column))

                elif _type == "is_name":

                    _check_results.addCheck(_check.hasPattern(_column, r"^[A-Za-z\s]+$"))
                    
                elif _type == "is_email":
                    _check_results.addCheck(_check.containsEmail(_column))
                    
                elif _type == "is_URL":
                    _check_results.addCheck(_check.containsURL(_column))
                
                else:

                    self.logger.info(f"check type ({_type}) is not reconized")

                    continue

                self.logger.info(f"Added check {_type} for column {_column} with assertion {_assertion}")

            except Exception as _e:
                self.logger.error(f"Adding check {_type} for column {_column} with assertion {_assertion} failed due to {_e}")



        _check_results = _check_results.run()
        _check_results_df = VerificationResult.checkResultsAsDataFrame(self.spark, _check_results)
        _check_results_df.write.mode("overwrite").json(output_url)
        return _check_results_df
    