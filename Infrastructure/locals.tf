locals {
  project               = "wwi"
  region                = "eu-west-1"
  root_path             = abspath(path.root)
  s3_bucket_name        = "${var.env}wwidatalakehouse"
  glue_db_names         = toset(["wwi_raw", "wwi_transformed", "wwi_presentation"])
  postgres_rds_port     = 5432
  mssql_server_name     = "2.tcp.eu.ngrok.io"
  mssql_port            = 19776
  mssql_username        = "sa"
  mssql_password        = "lotfy_123"
  mssql_database        = "WideWorldImporters"
  ecs_loadbalancer_port = 80

}