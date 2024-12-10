variable "rds_port" {
  description = "The port for rds"
  type        = number
  default     = 5432
}

variable "rds_allocated_storage" {
  description = "allocated storage for rds"
  type        = number
  default     = 20
}

variable "rds_instance_class" {
  description = "instance class for rds"
  type        = string
  default     = "db.t3.micro"
}



variable "vpc_id" {
  type    = string
  default = null
}

variable "multi_az" {
  description = "Define if the RDS instance on multiple availablity zones"
  type        = bool
}

variable "skip_final_snapshot" {
  description = " "
  type        = bool
}

variable "publicly_accessible" {
  description = "Define if the RDS instance allowing public access or not"
  type        = bool 
}


variable "identifier" {
  type = string
}


variable "prefix" {
  type = string
}

variable "sql_script_path" {
  type = string
}

variable "security_group_id" {
  description = "security group id for rds"
  type = string
}

variable "availability_zone" {
  type = string
}

variable "subnets" {
  type = list(string)
}