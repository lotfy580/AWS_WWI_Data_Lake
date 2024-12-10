resource "aws_mskconnect_custom_plugin" "plugin" {
  name         = var.custom_plugin_name
  content_type = "ZIP"
  location {
    s3 {
      bucket_arn = var.bucket_arn
      file_key   = var.plugin_s3_key
    }
  }
}


data "template_file" "MSK_connect_Configurations" {
  template = file(var.connector_configurations_path)

  vars = var.connector_configurations_vars
}

data "template_file" "MSKC_worker_Configurations" {
  template = file(var.worker_configurations_path)

  vars = var.worker_configurations_vars
}

data "template_file" "rendered_iam_policy" {
  template = file(var.iam_policy_path)
  vars     = var.iam_policy_vars
}

resource "aws_mskconnect_worker_configuration" "msk_connect_worker_configs" {
  name                    = var.worker_configs_name
  properties_file_content = data.template_file.MSKC_worker_Configurations.rendered
}


resource "aws_mskconnect_connector" "msk_connect" {
  name = var.connector_name

  kafkaconnect_version = "2.7.1"

  capacity {
    autoscaling {
      mcu_count        = var.autoscaling_mcu_count
      min_worker_count = var.autoscaling_min_work_count
      max_worker_count = var.autoscaling_max_worker_count

      scale_in_policy {
        cpu_utilization_percentage = var.scale_in_cpu_precentage
      }

      scale_out_policy {
        cpu_utilization_percentage = var.scale_out_cpu_precentage
      }
    }
  }

  connector_configuration = jsondecode(data.template_file.MSK_connect_Configurations.rendered)

  # worker_configuration {
  #   arn      = aws_mskconnect_worker_configuration.msk_connect_worker_configs.arn
  #   revision = aws_mskconnect_worker_configuration.msk_connect_worker_configs.latest_revision
  # }

  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = var.bootstrap_brokers
      vpc {
        security_groups = [var.msk_secuirty_group_id]
        subnets         = var.subnet_ids
      }
    }
  }

  kafka_cluster_client_authentication {
    authentication_type = "IAM"
  }

  kafka_cluster_encryption_in_transit {
    encryption_type = "TLS"
  }

  plugin {
    custom_plugin {
      arn      = aws_mskconnect_custom_plugin.plugin.arn
      revision = aws_mskconnect_custom_plugin.plugin.latest_revision
    }
  }

  log_delivery {
    worker_log_delivery {
      cloudwatch_logs {
        enabled   = true
        log_group = var.cloudwatch_log_group
      }
    }
  }

  service_execution_role_arn = aws_iam_role.msk_connect_iam_role.arn

  depends_on = [
    aws_mskconnect_custom_plugin.plugin,
    aws_iam_role_policy_attachment.msk_connector_policy_attachment
  ]
}


resource "aws_iam_role" "msk_connect_iam_role" {
  name               = var.iam_role_name
  assume_role_policy = file(var.iam_role_path)
}


resource "aws_iam_policy" "msk_connect_iam_policy" {
  name = var.iam_policy_name

  policy = data.template_file.rendered_iam_policy.rendered
}


resource "aws_iam_role_policy_attachment" "msk_connector_policy_attachment" {
  role       = aws_iam_role.msk_connect_iam_role.name
  policy_arn = aws_iam_policy.msk_connect_iam_policy.arn
  depends_on = [aws_iam_role.msk_connect_iam_role, aws_iam_policy.msk_connect_iam_policy]
}


