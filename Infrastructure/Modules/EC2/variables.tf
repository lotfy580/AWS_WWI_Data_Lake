variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "prefix" {
  type = string
}

variable "instance_ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "security_group_id" {
  type = string
}


variable "key_save_path" {
  type = string
}


variable "installation_script_path" {
    type = string
}

variable "iam_role" {
  type = string
}

variable "iam_policy" {
  type = string
}

variable "kafka_bootstrap" {
  type = string
}

variable "kafka_version" {
  type = string
}

variable "msk_cluster_name" {
  type = string
}

variable "bucket" {
  type = string
}

variable "subnet" {
  type = string
}
