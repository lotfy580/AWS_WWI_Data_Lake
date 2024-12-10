variable "s3_bucket_name" {
  description = "Name of s3 bucket, should be unique and no special characters"
  type = string
}

variable "assets_path" {
  description = "path to assets folder"
  type = string
}

variable "uploud_script" {
  description = "path of the python script that will uploud all assests to s3 bucket"
}