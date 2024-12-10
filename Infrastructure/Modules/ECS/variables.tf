variable "prefix" {
  type = string
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "container_definitions_json" {
  type = string
}

variable "service_platform_version" {
  type = string
}

variable "service_desired_count" {
  type = number
  default = 2
}

variable "ecs_iam_role" {
  type = string
}

variable "ecs_iam_policy" {
  type = string
}

variable "lb_port" {
  type = number
}

variable "subnets" {
  type = list(string)
}

variable "ecs_security_groups" {
  type = list(string)
}

variable "lb_security_groups" {
  type =list(string)
}

variable "container_port" {
  type = number
}


variable "vpc_id" {
  type = string
}

variable "kafka_bootstrap" {
  type = string
}

variable "cloudwatch_log_group" {
  type = string
}

variable "msk_cluster_name" {
  type = string
}

variable "account_id" {
  type = string
}

variable "region" {
  type = string
}


variable "container_image" {
  type = string
}

variable "deployment_minimum_healthy_percent" {
  type = number
}

variable "deployment_maximum_percent" {
  type = number
}