env = "dev"

# Postgres RDS

rds_instance_class  = "db.t3.micro"
multi_az            = false
skip_final_snapshot = true
publicly_accessible = true
allocated_storage   = 22

# Data Migration Service

dms_instance_class      = "dms.t3.micro"
dms_allocated_storage   = 5
dms_publicly_accessable = true
dms_multi_az            = false

# MSK Kafka Cluster

kafka_version        = "3.5.1"
broker_instance_type = "kafka.t3.small"
num_of_brokers       = 3
ebs_storage_size     = 5

# EC2 Kafka client

instance_ami  = "ami-05842291b9a0bd79f"
instance_type = "t2.micro"

# ECS Schema registry

container_port                     = 8181
cpu                                = 1024
memory                             = 2048
service_platform_version           = "LATEST"
service_desired_count              = 1
deployment_minimum_healthy_percent = 50
deployment_maximum_percent         = 100

# MSK Connector Debezium

debezium_autoscaling_mcu_count        = 1
debezium_autoscaling_min_work_count   = 1
debezium_autoscaling_max_worker_count = 2
debezium_scale_in_cpu_precentage      = 20
debezium_scale_out_cpu_precentage     = 80

# MSK Connector s3sink

s3sink_autoscaling_mcu_count        = 1
s3sink_autoscaling_min_work_count   = 1
s3sink_autoscaling_max_worker_count = 2
s3sink_scale_in_cpu_precentage      = 20
s3sink_scale_out_cpu_precentage     = 80