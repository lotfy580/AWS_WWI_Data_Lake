output "rds_sg_id" {
  value = aws_security_group.postgres_rds_sg.id
}

output "dms_sg_id" {
  value = aws_security_group.dms_sg.id
}

output "msk_cluster_sg_id" {
  value = aws_security_group.msk_cluster_sg.id
}

output "ecs_registry_sg_id" {
  value = aws_security_group.ecs_registry_sg.id
}

output "kafka_client_sg_id" {
  value = aws_security_group.kafka_client_sg.id
}

output "load_balancer_sg_id" {
  value = aws_security_group.lb_registry_sg.id
}

output "msk_dbzm_sg_id" {
  value = aws_security_group.msk_connect_dbzm_sg.id
}

output "msk_s3sink_sg_id" {
  value = aws_security_group.msk_connect_s3sink_sg.id
}