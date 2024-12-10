################################################################################
# Set custom configuration for MSK Cluster
################################################################################

resource "aws_msk_configuration" "Kafka_cluster_configurations" {
  kafka_versions = [var.kafka_version]
  name           = "${var.prefix}-Kafka-Configs"

  server_properties = <<PROPERTIES
auto.create.topics.enable = true
delete.topic.enable = true
min.insync.replicas = 2
PROPERTIES
}


################################################################################
# Initialize managed Service for Kafka cluster
################################################################################

resource "aws_msk_cluster" "Kafka_cluster" {
  cluster_name           = "${var.prefix}-Kafka-Cluster"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.num_of_brokers

  broker_node_group_info {
    instance_type = var.broker_instance_type
    client_subnets = var.subnet_ids
    storage_info {
      ebs_storage_info {
        volume_size = var.ebs_storage_size
      }
    }
    security_groups = [var.security_group_id]
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.Kafka_cluster_configurations.arn
    revision = aws_msk_configuration.Kafka_cluster_configurations.latest_revision
  }



  logging_info {

    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk_log_group.name
      }
    }
  }

  client_authentication {
    sasl {
      iam   = try(true, null)
      scram = try(false, null)
    }
  }
   

  
  
  depends_on = [ aws_cloudwatch_log_group.msk_log_group ]
}

resource "aws_cloudwatch_log_group" "msk_log_group" {
  name = "${var.prefix}-kafka-logs"
}