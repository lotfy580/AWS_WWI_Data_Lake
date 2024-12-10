
variable "prefix" {
  type = string
}

variable "dms_instance_class" {
  type    = string
  default = "dms.t3.micro"
}

variable "dms_allocated_storage" {
  type    = number
  default = 5
}

variable "dms_publicly_accessable" {
  type = bool
}

variable "mssql_server_name" {
  type =string
}

variable "mssql_username" {
  type =string
}

variable "mssql_password" {
  type =string
}

variable "mssql_DB_name" {
  type =string
}

variable "mssql_port" {
  type = number
}

variable "postgres_endpoint" {
  type = string
}

variable "postgres_username" {
  type = string
}

variable "postgres_password" {
  type = string
}

variable "postgres_DB_name" {
  type = string
}

variable "postgres_port" {
  type = number
}

variable "table_mappings_json_path" {
  type = string
}

variable "replicaation_setting_json_path" {
  type = string
}

variable "dms_multi_az" {
  type = bool
}

variable "vpc_id" {
  type = string
}

variable "dms_iam_role_path" {
  type = string
}

variable "dms_iam_policy_path" {
  type = string
}


variable "security_group_id" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "subnets" {
  type = list(string)
}