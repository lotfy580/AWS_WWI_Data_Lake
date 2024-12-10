
################################################################################
# Fire up a Replication instance                              
################################################################################

resource "aws_dms_replication_subnet_group" "dms_subnet_group" {
  replication_subnet_group_id = "${var.prefix}-dms-subnet-group"
  replication_subnet_group_description = "subnet group for dms replication instance"
  subnet_ids = var.subnets

  tags = {
    name = "${var.prefix}-dms-subnet-group"
  }
}

resource "aws_dms_replication_instance" "data_migration_instance" {
  replication_instance_id    = "${var.prefix}-DMS-instance"
  replication_instance_class = var.dms_instance_class
  allocated_storage          = var.dms_allocated_storage
  publicly_accessible        = var.dms_publicly_accessable
  multi_az                   = var.dms_multi_az
  vpc_security_group_ids     = [var.security_group_id]
  availability_zone          = var.dms_multi_az ? null : var.availability_zone 
  replication_subnet_group_id = aws_dms_replication_subnet_group.dms_subnet_group.id
  depends_on = [
    aws_iam_role_policy_attachment.dms_vpc_policy_attachment,
    aws_iam_policy.dms_vpc_policy,
    aws_iam_role.dms_vpc_role
  ]
}

################################################################################
# Set an End point for Postgres-RDS
################################################################################

resource "aws_dms_endpoint" "mssql_source" { 
  endpoint_id   = "${var.prefix}-mssql-source"
  endpoint_type = "source"
  engine_name   = "sqlserver"
  ssl_mode      = "require"
  server_name   = var.mssql_server_name
  username      = var.mssql_username
  password      = var.mssql_password
  port          = var.mssql_port
  database_name = var.mssql_DB_name
}

resource "aws_dms_endpoint" "postgres_target" { 
  endpoint_id   = "${var.prefix}-postgres-target"
  endpoint_type = "target"
  engine_name   = "postgres"
  ssl_mode      = "require"
  server_name   = var.postgres_endpoint
  username      = var.postgres_username
  password      = var.postgres_password
  port          = var.postgres_port
  database_name = var.postgres_DB_name
}

################################################################################
# Configure IAM role for DMS  
################################################################################

resource "aws_iam_role" "dms_vpc_role" {
  name = "${var.prefix}-dms-role"
  assume_role_policy = file(var.dms_iam_role_path)
}

################################################################################
# Configure IAM Policy for DMS 
################################################################################

resource "aws_iam_policy" "dms_vpc_policy" {
  name        = "${var.prefix}-dms-policy"
  description = "Policy for DMS to access VPC"

  policy = file(var.dms_iam_policy_path)
}


################################################################################
# Attach IAM policy to IAM role 
################################################################################

resource "aws_iam_role_policy_attachment" "dms_vpc_policy_attachment" {
  role       = aws_iam_role.dms_vpc_role.name
  policy_arn = aws_iam_policy.dms_vpc_policy.arn
  depends_on = [
    aws_iam_role.dms_vpc_role,
    aws_iam_policy.dms_vpc_policy
  ]
}


################################################################################
# Configure a Replication task to Start Migration                              
################################################################################

resource "aws_dms_replication_task" "migration_task" {
  replication_task_id       = "${var.prefix}-DMS-task"
  migration_type            = "full-load"
  table_mappings            = file(var.table_mappings_json_path)
  replication_instance_arn  = aws_dms_replication_instance.data_migration_instance.replication_instance_arn
  source_endpoint_arn       = aws_dms_endpoint.mssql_source.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.postgres_target.endpoint_arn
  replication_task_settings = file(var.replicaation_setting_json_path)
  start_replication_task    = true

  depends_on = [
    aws_dms_replication_instance.data_migration_instance,
    aws_dms_endpoint.postgres_target,
    aws_dms_endpoint.mssql_source
  ]
}