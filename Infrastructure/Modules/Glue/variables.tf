variable "glue_db_names" {
  description = "list of glue database names, should follow the exact same order:raw, sliver, gold"
  type = any
}

variable "postgres_database" {
  description = "postgres Database which will connect to glue"
  type = string
}

variable "postgres_endpoint" {
  description = "postgres Endpoint that will connect to glue"
  type = string
}

variable "postgres_port" {
  description = "postgres port"
  type = number
}

variable "postgres_user_name" {
  type = string
}

variable "postgres_password" {
  type = string
}

variable "s3_bucket_name" {
  description = "Name of s3 bucket, should be unique and no special characters"
  type = string
}

variable "postgres_region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "postgres_cluster_id" {
  type = string
}

variable "subnet_id" {
  description = "ID of subnet which postgres and glue on"
  type = string
}

variable "availability_zone" {
  description = "List of availability zones of VPC"
  type = string
}

variable "vpc_id" {
  type = string
}