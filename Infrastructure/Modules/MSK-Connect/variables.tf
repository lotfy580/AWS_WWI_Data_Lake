variable "bootstrap_brokers" {
  type = string
}

variable "subnet_ids" {
  description = "list of vpc subnet ids for MSK cluster"
  type        = list(string)
}

variable "bucket_name" {
  description = "s3 bucket name that stores kafka connect plugins"
  type        = string
}

variable "bucket_arn" {
  description = "s3 bucket arn that stores kafka connect plugins"
  type        = string
}
variable "plugin_s3_key" {
  type = string
}

variable "custom_plugin_name" {
  type = string
}

variable "cloudwatch_log_group" {
  type = string
}

variable "connector_configurations_path" {
  type = string
}

variable "connector_configurations_vars" {
  type    = map(any)
  default = {}
}

variable "worker_configs_name" {
  type = string
}

variable "worker_configurations_path" {
  type = string
}

variable "worker_configurations_vars" {
  type    = map(any)
  default = {}
}

variable "msk_secuirty_group_id" {
  type = string
}

variable "connector_name" {
  type = string
}

variable "autoscaling_mcu_count" {
  type = number
}

variable "autoscaling_min_work_count" {
  type = number
}

variable "autoscaling_max_worker_count" {
  type = number
}

variable "scale_in_cpu_precentage" {
  type = number
}

variable "scale_out_cpu_precentage" {
  type = number
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "iam_role_name" {
  type = string
}

variable "iam_role_path" {
  type = string
}

variable "iam_policy_name" {
  type = string
}

variable "iam_policy_path" {
  type = string
}

variable "iam_policy_vars" {
  type    = map(any)
}