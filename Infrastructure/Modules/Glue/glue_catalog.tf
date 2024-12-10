################################################################################
#                            Create IAM role for glue                          #
################################################################################

resource "aws_iam_role" "glue_service_role" {
  name = "glue_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

################################################################################
#                          Create IAM Policy for glue                          #
################################################################################

resource "aws_iam_policy" "glue_access_policy" {
  name = "GlueAccessPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:DescribeDBSnapshots",
          "rds:DescribeDBSubnetGroups",
          "rds:DescribeDBParameterGroups",
          "rds:DescribeDBSecurityGroups",
          "rds:DescribeDBLogFiles",
          "rds:DescribeEvents",
          "rds:DescribeEventCategories",
          "rds:DescribeOptionGroups",
          "rds:Connect"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "rds-db:connect"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource = "*",
        Condition = {
          "StringEquals": {
            "aws:ResourceTag/red-hat": "true"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "glue:*"
        ],
        Resource = "*"
      }
    ]
  })
}

################################################################################
#                         Attach policies to IAM role                          #
################################################################################

resource "aws_iam_role_policy_attachment" "glue_policy_attachment" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = aws_iam_policy.glue_access_policy.arn
}

################################################################################
#                        Create Security group for glue                        #
################################################################################

resource "aws_security_group" "glue_security_group" {
  name   = "glue-security-group"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 0
    to_port     = 65535
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

################################################################################
#                            Create Catalog Databases                          #
################################################################################

resource "aws_glue_catalog_database" "glue_dbs" {
  for_each = var.glue_db_names
  name = "${each.value}"
  
}

################################################################################
#                       Create glue connection to postgres                     #
################################################################################

# resource "aws_glue_connection" "glue_connection_to_postgres" {
#   name = "glue-postgres-conn"  
#   connection_properties = {
#     JDBC_CONNECTION_URL = "jdbc:postgres://${var.postgres_endpoint}:${var.postgres_port}/${var.postgres_database}"
#     USERNAME            = var.postgres_user_name
#     PASSWORD            = var.postgres_password
#   }
#   physical_connection_requirements {
#     security_group_id_list = [ aws_security_group.glue_security_group.id ]
#     availability_zone = var.availability_zone
#     subnet_id = var.subnet_id
#   }
# }

################################################################################
#                      Create Crawler that targets postgres                    #
################################################################################

# resource "aws_glue_crawler" "crawler" {
#   database_name = var.glue_db_name
#   name          = "wideworldimporters-postgres"
#   role          = aws_iam_role.glue_service_role.arn

#   jdbc_target {
#     connection_name = aws_glue_connection.glue_connection_to_postgres.name
#     path            = "%/%"
#   }
#   depends_on = [ 
#     aws_iam_role.glue_service_role,
#     aws_iam_policy.glue_access_policy,
#     aws_iam_role_policy_attachment.glue_policy_attachment,
#     aws_glue_catalog_database.glue_dbs,
#     aws_glue_connection.glue_connection_to_postgres
#    ]
# }
