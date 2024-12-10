output "vpc_id" {
  value = aws_vpc.My_vpc.id
}

output "subnet_az_1_id" {
  value = aws_subnet.subnet_az_1.id
}

output "subnet_az_2_id" {
  value = aws_subnet.subnet_az_2.id
}

output "subnet_az_3_id" {
  value = aws_subnet.subnet_az_3.id
}