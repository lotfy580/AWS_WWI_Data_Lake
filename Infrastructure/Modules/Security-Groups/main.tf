resource "aws_security_group" "postgres_rds_sg" {
  name        = "${var.prefix}-rds-sg"
  description = "security_group for postgres RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.postgres_port
    to_port         = var.postgres_port
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [ aws_security_group.msk_connect_dbzm_sg.id ]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "dms_sg" {
  name        = "${var.prefix}-dms-sg"
  description = "secutrity group for DMS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.postgres_port
    to_port         = var.postgres_port
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.postgres_rds_sg.id]
  }

  ingress {
    from_port   = var.mssql_port
    to_port     = var.mssql_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "msk_cluster_sg" {
  name        = "${var.prefix}-msk-cluster-sg"
  description = "allow tcp connection to kafka on iam auth port from msk connectors, kafka client and schema registry"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 9098
    to_port   = 9098
    protocol  = "tcp"
    security_groups = [
      aws_security_group.kafka_client_sg.id,
      aws_security_group.ecs_registry_sg.id,
      aws_security_group.lb_registry_sg.id,
      aws_security_group.msk_connect_dbzm_sg.id,
      aws_security_group.msk_connect_s3sink_sg.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "kafka_client_sg" {
  name        = "${var.prefix}-kafka-client-sg"
  description = "allow ssh to kafka client on ec2"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




resource "aws_security_group" "ecs_registry_sg" {
  name        = "${var.prefix}-ecs-registry-sg"
  description = "security group for confluent schema registry app on ecs"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.lb_registry_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "lb_registry_sg" {
  name        = "${var.prefix}-lb-registry-sg"
  description = "security group for ecs load balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port = var.lb_port
    to_port   = var.lb_port
    protocol  = "tcp"
    security_groups = [
      aws_security_group.kafka_client_sg.id,
      aws_security_group.msk_connect_dbzm_sg.id,
      aws_security_group.msk_connect_s3sink_sg.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "lb_msk_cluster_rule" {
  security_group_id = aws_security_group.lb_registry_sg.id
  type = "ingress"
  to_port = 0
  from_port = 0
  protocol = "tcp"
  source_security_group_id = aws_security_group.msk_cluster_sg.id
}

resource "aws_security_group_rule" "lb_ecs_rule" {
  security_group_id = aws_security_group.lb_registry_sg.id
  type = "ingress"
  to_port = 0
  from_port = 0
  protocol = "tcp"
  source_security_group_id = aws_security_group.ecs_registry_sg.id
}

resource "aws_security_group" "msk_connect_dbzm_sg" {
  name        = "${var.prefix}-msk-connect-dbzm-sg"
  description = "security group for debezium on msk connect"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "tcp"
    security_groups = [aws_security_group.kafka_client_sg.id]
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "msk_connect_s3sink_sg" {
  name        = "${var.prefix}-msk-connect-s3sink-sg"
  description = "security group for s3 sink on msk connect"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "tcp"
    security_groups = [aws_security_group.kafka_client_sg.id]
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}