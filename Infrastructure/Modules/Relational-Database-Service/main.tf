################################################################################
# set parmater group for RDS
################################################################################

resource "aws_db_parameter_group" "rds_parameters" {
  name        = "${var.prefix}-postgresql-parameter-group"
  family      = "postgres16"
  description = "Parameter group for postgres RDS"
  
 parameter {
    name  = "rds.logical_replication"
    value = 1
    apply_method = "pending-reboot"
  }
}


################################################################################
# Setup AWS RDS
################################################################################

resource "aws_db_subnet_group" "postgres_subnet_group" {
  name = "${var.prefix}-postgres-subnet-group"
  subnet_ids = var.subnets

  tags = {
    name = "${var.prefix}-postgres-subnet-group"
  }
}


resource "aws_db_instance" "Postgres_db" {
  allocated_storage      = var.rds_allocated_storage
  engine                 = "postgres"
  engine_version         = "16.3"
  multi_az               = var.multi_az
  identifier             = var.identifier
  instance_class         = var.rds_instance_class
  db_name                = "WideWorldImporters"
  username               = "lotfy"
  password               = "lotfy_123"
  skip_final_snapshot    = var.skip_final_snapshot
  publicly_accessible    = var.publicly_accessible
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.postgres_subnet_group.name 
  availability_zone      = var.multi_az ? null : var.availability_zone 
  parameter_group_name   = aws_db_parameter_group.rds_parameters.name
  tags = {
    name = "${var.prefix}-PostgresRDS"
  }
}

################################################################################
# Execute local remote task to run schema conversion script on RDS                    
################################################################################

resource "null_resource" "exec_schema_conversion_script" {
  provisioner "local-exec" {
    command = <<EOT
            cd C:\Program Files\PostgreSQL\14\bin && psql -h ${aws_db_instance.Postgres_db.address} -U ${aws_db_instance.Postgres_db.username} -d ${aws_db_instance.Postgres_db.db_name} -f ${var.sql_script_path}
            EOT
    environment = {
      PGPASSWORD = aws_db_instance.Postgres_db.password
    }
  }

  depends_on = [aws_db_instance.Postgres_db]
}
