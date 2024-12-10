# Discription: script to uploud assests dir to S3 bucket
# Author: Lotfy Ashmawy

import os 
import boto3

# get enviroment variables from terraform
env_name    = os.getenv("env")
dir_path    = os.getenv("assets_dir_path").replace("\\", "/")
bucket_name = os.getenv("bucket_name")


def uploud_to_s3(dir_path:str, bucket_name:str, env:str) -> None:
    
    s3 = boto3.resource("s3")
    bucket = s3.Bucket(bucket_name) 


def uploud_dir_to_s3(dir_path:str, bucket_name:str) -> None:
    # takes a local directory path and s3 bucket name.
    # uplouds the local dir with all its files to s3 bucket.
    # the bucket dir will have the same structure as the local dir.
    # any empty sub-dir will be ignored.
    # if a file is already exist in bucket dir, it will not be reuploaded.
       
    s3 = boto3.resource("s3")
    bucket = s3.Bucket(bucket_name)
    dir_name = dir_path.split('/')[-1]
    
    for dirpath, _, filenames in os.walk(dir_path):
        
        for filename in filenames:
            
            filepath = os.path.join(dirpath, filename).replace("\\", "/")
            file_inner_path = filepath.split(f"{dir_name}/")[-1]
            
            if any(object.key.split("/")[-1] == filename for object in bucket.objects.filter(Prefix=f"{dir_name}/")):
                print(f"{filename} is already exist in s3 bucket!")
            else:
                try:
                    bucket.upload_file(filepath, f"{dir_name}/{file_inner_path}")
                    print(f"{filename} Uploaded!")
                except Exception as e:
                    print(f"ERROR Python Uploading {filename} to s3: {e}")
            
        
        

if __name__=="__main__":
    
    uploud_dir_to_s3(dir_path, bucket_name)