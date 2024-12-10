variable "prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "kafka_version" {
  description = "the version of apache kafka that runs on MSK"
  type        = string
}

variable "broker_instance_type" {
  description = "the instance of MSK"
  type        = string
}

variable "num_of_brokers" {
  description = "number of MSK nodes"
  type        = number
}

variable "subnet_ids" {
  description = "list of vpc subnet ids for MSK cluster"
  type        = list(string)
}

variable "ebs_storage_size" {
  description = "the size of storage for broker"
  type        = number
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}