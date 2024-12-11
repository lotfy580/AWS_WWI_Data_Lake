variable "env" {
  type = string
}

# Postgres RDS

variable "rds_instance_class" {
  type = string
}

variable "multi_az" {
  type = bool
}

variable "skip_final_snapshot" {
  type = bool
}

variable "publicly_accessible" {
  type = bool
}

variable "allocated_storage" {
  type = number
}

# Data Migration Service

variable "dms_instance_class" {
  type = string
}

variable "dms_allocated_storage" {
  type = number
}

variable "dms_publicly_accessable" {
  type = bool
}

variable "dms_multi_az" {
  type = bool
}

# Kafka Cluster

variable "kafka_version" {
  type = string
}

variable "broker_instance_type" {
  type = string
}

variable "num_of_brokers" {
  type = number
}

variable "ebs_storage_size" {
  type = number
}

# EC2 Kafka Client

variable "instance_ami" {
  type = string
}

variable "instance_type" {
  type = string
}

# ECS Schema registry

variable "container_port" {
  type = number
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "service_platform_version" {
  type = string
}

variable "service_desired_count" {
  type = number
}

variable "deployment_minimum_healthy_percent" {
  type = number
}

variable "deployment_maximum_percent" {
  type = number
}

# MSK Connect Debezium

variable "debezium_autoscaling_mcu_count" {
  type = number
}

variable "debezium_autoscaling_min_work_count" {
  type = number
}

variable "debezium_autoscaling_max_worker_count" {
  type = number
}

variable "debezium_scale_in_cpu_precentage" {
  type = number
}

variable "debezium_scale_out_cpu_precentage" {
  type = number
}

# MSK Connect S3 Sink

variable "s3sink_autoscaling_mcu_count" {
  type = number
}

variable "s3sink_autoscaling_min_work_count" {
  type = number
}

variable "s3sink_autoscaling_max_worker_count" {
  type = number
}

variable "s3sink_scale_in_cpu_precentage" {
  type = number
}

variable "s3sink_scale_out_cpu_precentage" {
  type = number
}