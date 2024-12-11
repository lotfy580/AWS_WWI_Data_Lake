
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available_zone" {}


module "vpc" {
  source             = "./Modules/VPC"
  prefix             = "${local.project}-${var.env}"
  region             = local.region 
  availability_zones = data.aws_availability_zones.available_zone.names
}

module "security_groups" {
  source        = "./Modules/Security-Groups"
  prefix        = "${local.project}-${var.env}"
  vpc_id        = module.vpc.vpc_id
  lb_port       = local.ecs_loadbalancer_port
  postgres_port = local.postgres_rds_port
  mssql_port    = local.mssql_port

  depends_on = [module.vpc]
}


module "postgres_rds" {
  source                = "./Modules/Relational-Database-Service"
  prefix                = "${local.project}-${var.env}"
  rds_instance_class    = var.rds_instance_class
  identifier            = "postgres-rds"
  multi_az              = var.multi_az
  skip_final_snapshot   = var.skip_final_snapshot
  publicly_accessible   = var.publicly_accessible
  rds_allocated_storage = var.allocated_storage
  rds_port              = 5432
  vpc_id                = module.vpc.vpc_id
  security_group_id     = module.security_groups.rds_sg_id
  availability_zone     = data.aws_availability_zones.available_zone.names[0]

  subnets = [
    module.vpc.subnet_az_1_id,
    module.vpc.subnet_az_2_id,
    module.vpc.subnet_az_3_id
  ]

  sql_script_path = "${local.root_path}/assets/Postgres/schema_conversion.sql"

  depends_on = [module.vpc, module.security_groups]
}


module "DMS" {
  source = "./Modules/Data-Migration-Service"
  prefix = "${local.project}-${var.env}"

  #replication instance
  dms_instance_class      = var.dms_instance_class
  dms_allocated_storage   = var.dms_allocated_storage
  dms_publicly_accessable = var.dms_publicly_accessable
  dms_multi_az            = var.dms_multi_az
  dms_iam_role_path       = "${local.root_path}/assets/IAM/DMS_IAM_Role.json"
  dms_iam_policy_path     = "${local.root_path}/assets/IAM/DMS_IAM_Policy.json"
  vpc_id                  = module.vpc.vpc_id
  security_group_id       = module.security_groups.dms_sg_id
  availability_zone       = data.aws_availability_zones.available_zone.names[0]

  subnets = [
    module.vpc.subnet_az_1_id,
    module.vpc.subnet_az_2_id,
    module.vpc.subnet_az_3_id
    ] 

  #endpoints
  mssql_server_name = local.mssql_server_name
  mssql_username    = local.mssql_username
  mssql_password    = local.mssql_password
  mssql_port        = local.mssql_port
  mssql_DB_name     = local.mssql_database
  postgres_endpoint = module.postgres_rds.rds_address
  postgres_username = module.postgres_rds.rds_username
  postgres_password = module.postgres_rds.rds_password
  postgres_port     = module.postgres_rds.rds_port
  postgres_DB_name  = module.postgres_rds.rds_database

  #replication_task
  replicaation_setting_json_path = "${local.root_path}/assets/Data Migration Service/replication_setting.json"
  table_mappings_json_path       = "${local.root_path}/assets/Data Migration Service/table_mapping.json"

  depends_on = [ module.postgres_rds ]
}


module "s3" {
  source         = "./Modules/S3"
  s3_bucket_name = local.s3_bucket_name
  assets_path    = "${local.root_path}/assets"
  uploud_script  = "${local.root_path}/assets/s3/Upload_assets.py"
}


# module "Glue" {
#   source              = "./05-AWS-Glue"
#   glue_db_names       = local.glue_db_names
#   postgres_endpoint   = module.postgres_rds.endpoint
#   postgres_user_name  = var.postgres_user_name
#   postgres_password   = var.postgres_password
#   postgres_database   = var.postgres_db_name
#   postgres_port       = var.postgres_port
#   account_id          = data.aws_caller_identity.current.account_id
#   postgres_region     = local.region
#   s3_bucket_name      = local.s3_bucket_name
#   postgres_cluster_id = module.postgres_rds.cluster_id
#   vpc_id              = data.aws_vpc.default_vpc.id
#   availability_zone   = data.aws_availability_zones.available_zone.names[0]
#   subnet_id           = data.aws_subnets.default_vpc_subnets.ids[0]
#   depends_on          = [data.aws_vpc.default_vpc]
# }

module "push_registry_image" {
  source          = "./Modules/ECR"
  prefix          = "${local.project}-${var.env}"
  dockerfile_path = "${local.root_path}/assets/Kafka/schema_registry/dockerfile"
  region          = local.region
  account_id      = data.aws_caller_identity.current.account_id

  depends_on = [module.s3]

}


module "Kafka_cluster" {
  source               = "./Modules/MSK-Cluster"
  prefix               = "${local.project}-${var.env}"
  kafka_version        = var.kafka_version
  broker_instance_type = var.broker_instance_type
  num_of_brokers       = var.num_of_brokers
  ebs_storage_size     = var.ebs_storage_size
  account_id           = data.aws_caller_identity.current.account_id
  region               = local.region
  vpc_id               = module.vpc.vpc_id
  security_group_id    = module.security_groups.msk_cluster_sg_id
  subnet_ids = [
    module.vpc.subnet_az_1_id,
    module.vpc.subnet_az_2_id,
    module.vpc.subnet_az_3_id
  ]

  depends_on = [module.s3, module.vpc, module.security_groups, module.push_registry_image]
}



module "kafka_client" {
  source                   = "./Modules/EC2"
  prefix                   = "${local.project}-${var.env}"
  instance_ami             = var.instance_ami
  instance_type            = var.instance_type
  kafka_bootstrap          = module.Kafka_cluster.msk_bootstrap_brokers_sasl_iam
  kafka_version            = module.Kafka_cluster.msk_kafka_version
  msk_cluster_name         = module.Kafka_cluster.msk_cluster_name
  region                   = local.region
  account_id               = data.aws_caller_identity.current.account_id
  bucket                   = local.s3_bucket_name
  subnet                   = module.vpc.subnet_az_1_id
  security_group_id        = module.security_groups.kafka_client_sg_id
  key_save_path            = "~/.ssh/key.pem"
  installation_script_path = "${local.root_path}/assets/Kafka/kafka_client/Kafka_client_installation.sh"
  iam_role                 = "${local.root_path}/assets/IAM/Kafka_Client_IAM_Role.json"
  iam_policy               = "${local.root_path}/assets/IAM/Kafka_Client_IAM_policy.json"

  depends_on = [module.Kafka_cluster]
}



module "Schema_registry" {
  source           = "./Modules/ECS"
  prefix           = "${local.project}-${var.env}"
  ecs_iam_role     = "${local.root_path}/assets/IAM/Kafka_registry_ECS_IAM_Role.json"
  ecs_iam_policy   = "${local.root_path}/assets/IAM/Kafka_registry_ECS_IAM_Policy.json"
  msk_cluster_name = module.Kafka_cluster.msk_cluster_name

  # Task Definition
  container_image            = "${module.push_registry_image.repository_url}:latest"
  container_port             = var.container_port
  cpu                        = var.cpu
  memory                     = var.memory
  container_definitions_json = "${local.root_path}/assets/Kafka/schema_registry/ECS_registry_container_configs.json"
  region                     = local.region
  account_id                 = data.aws_caller_identity.current.account_id
  kafka_bootstrap            = module.Kafka_cluster.msk_bootstrap_brokers_sasl_iam
  cloudwatch_log_group       = module.Kafka_cluster.MSK_cloudwatch_log_group_name

  # ECS Service
  service_platform_version           = var.service_platform_version
  service_desired_count              = var.service_desired_count
  ecs_security_groups                = [module.security_groups.ecs_registry_sg_id]
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  subnets = [
    module.vpc.subnet_az_1_id,
    module.vpc.subnet_az_2_id,
    module.vpc.subnet_az_3_id
  ]

  # Load Balancer
  lb_port            = local.ecs_loadbalancer_port
  vpc_id             = module.vpc.vpc_id
  lb_security_groups = [module.security_groups.load_balancer_sg_id]

  depends_on = [module.push_registry_image, module.Kafka_cluster]
}



module "kafka_connect_debezium" {
  source                       = "./Modules/MSK-Connect"
  connector_name               = "${local.project}-${var.env}-CDC-connector"
  autoscaling_mcu_count        = var.debezium_autoscaling_mcu_count
  autoscaling_min_work_count   = var.debezium_autoscaling_min_work_count
  autoscaling_max_worker_count = var.debezium_autoscaling_max_worker_count
  scale_in_cpu_precentage      = var.debezium_scale_in_cpu_precentage
  scale_out_cpu_precentage     = var.debezium_scale_out_cpu_precentage
  bootstrap_brokers            = module.Kafka_cluster.msk_bootstrap_brokers_sasl_iam
  msk_secuirty_group_id        = module.security_groups.msk_dbzm_sg_id
  cloudwatch_log_group         = module.Kafka_cluster.MSK_cloudwatch_log_group_name
  bucket_name                  = local.s3_bucket_name
  bucket_arn                   = module.s3.bucket_arn
  region                       = local.region
  account_id                   = data.aws_caller_identity.current.account_id
  iam_role_name                = "${local.project}-${var.env}-msk-debezium-role"
  iam_role_path                = "${local.root_path}/assets/IAM/Kafka_Connect_IAM_Role.json"
  iam_policy_name              = "${local.project}-${var.env}-msk-debezium-policy"
  iam_policy_path              = "${local.root_path}/assets/IAM/Kafka_Debezium_Connect_IAM_Policy.json"

  iam_policy_vars = {
    cluster_name = module.Kafka_cluster.msk_cluster_name
    region       = local.region
    account_id   = data.aws_caller_identity.current.account_id
  }

  custom_plugin_name = "${local.project}-${var.env}-debezium-plugin"
  plugin_s3_key      = "assets/Kafka/kafka_connect_debezium/Debezium-Avro-plugin.zip"

  connector_configurations_path = "${local.root_path}/assets/Kafka/kafka_connect_debezium/debezium_connector_configs.json"

  connector_configurations_vars = {
    DB_host      = module.postgres_rds.rds_address
    DB_user      = module.postgres_rds.rds_username
    DB_port      = module.postgres_rds.rds_port
    DB_password  = module.postgres_rds.rds_password
    DB_name      = module.postgres_rds.rds_database
    registry_url = module.Schema_registry.lb_url
  }

  worker_configs_name        = "${local.project}-${var.env}-debezium-worker-configs"
  worker_configurations_path = "${local.root_path}/assets/Kafka/kafka_connect_debezium/debezium_worker_configs.properties"

  worker_configurations_vars = {
    registry_url = module.Schema_registry.lb_url
  }

  subnet_ids = [
    module.vpc.subnet_az_1_id,
    module.vpc.subnet_az_2_id,
    module.vpc.subnet_az_3_id
  ]

  depends_on = [module.Kafka_cluster, module.Schema_registry]
}


module "kafka_connect_s3_sink" {
  source                       = "./Modules/MSK-Connect"
  connector_name               = "${local.project}-${var.env}-s3-connector"
  autoscaling_mcu_count        = var.s3sink_autoscaling_mcu_count
  autoscaling_min_work_count   = var.s3sink_autoscaling_min_work_count
  autoscaling_max_worker_count = var.s3sink_autoscaling_max_worker_count
  scale_in_cpu_precentage      = var.s3sink_scale_in_cpu_precentage
  scale_out_cpu_precentage     = var.s3sink_scale_out_cpu_precentage
  bootstrap_brokers            = module.Kafka_cluster.msk_bootstrap_brokers_sasl_iam
  msk_secuirty_group_id        = module.security_groups.msk_s3sink_sg_id
  cloudwatch_log_group         = module.Kafka_cluster.MSK_cloudwatch_log_group_name
  bucket_name                  = local.s3_bucket_name
  bucket_arn                   = module.s3.bucket_arn
  region                       = local.region
  account_id                   = data.aws_caller_identity.current.account_id
  iam_role_name                = "${local.project}-${var.env}-msk-s3sink-role"
  iam_role_path                = "${local.root_path}/assets/IAM/Kafka_Connect_IAM_Role.json"
  iam_policy_name              = "${local.project}-${var.env}-msk-s3sink-policy"
  iam_policy_path              = "${local.root_path}/assets/IAM/Kafka_S3Sink_Connect_IAM_Policy.json"

  iam_policy_vars = {
    cluster_name = module.Kafka_cluster.msk_cluster_name
    region       = local.region
    account_id   = data.aws_caller_identity.current.account_id
    bucket       = local.s3_bucket_name
  }

  custom_plugin_name = "${local.project}-${var.env}-s3sink-plugin"
  plugin_s3_key      = "assets/Kafka/kafka_connect_s3sink/confluentinc-kafka-connect-s3-10.5.13.zip"

  connector_configurations_path = "${local.root_path}/assets/Kafka/kafka_connect_s3sink/s3sink_connector_configs.json"

  connector_configurations_vars = {
    registry_url = module.Schema_registry.lb_url
    region       = local.region
    bucket_name  = local.s3_bucket_name
  }

  worker_configs_name        = "${local.project}-${var.env}-s3sink-worker-configs"
  worker_configurations_path = "${local.root_path}/assets/Kafka/kafka_connect_s3sink/s3sink_worker_configs.properties"

  worker_configurations_vars = {
    registry_url = module.Schema_registry.lb_url
  }

  subnet_ids = [
    module.vpc.subnet_az_1_id,
    module.vpc.subnet_az_2_id,
    module.vpc.subnet_az_3_id
  ]

  depends_on = [module.Kafka_cluster, module.Schema_registry, module.kafka_connect_debezium]
}