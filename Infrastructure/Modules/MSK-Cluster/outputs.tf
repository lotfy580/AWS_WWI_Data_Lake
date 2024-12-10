output "msk_bootstrap_brokers_sasl_iam" {
  value = aws_msk_cluster.Kafka_cluster.bootstrap_brokers_sasl_iam
}

output "MSK_cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.msk_log_group.name
}

output "msk_kafka_version" {
  value = aws_msk_cluster.Kafka_cluster.kafka_version
}

output "msk_cluster_name" {
  value = aws_msk_cluster.Kafka_cluster.cluster_name
}