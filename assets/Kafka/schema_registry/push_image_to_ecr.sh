#!/bin/bash

# Description: script to build confluent schema regisry image from dockerfile and push it to ECR 
# Author: Lotfy Ashmawy

aws ecr get-login-password --region ${region} | \
docker login --username AWS --password-stdin ${account_id}.dkr.ecr.${region}.amazonaws.com

docker build -f ${dockerfile_path} -t schema_registry:latest . && \ 
docker tag schema_registry ${account_id}.dkr.ecr.${region}.amazonaws.com/schema_registry:latest && \
docker push ${account_id}.dkr.ecr.${region}.amazonaws.com/schema_registry:latest
