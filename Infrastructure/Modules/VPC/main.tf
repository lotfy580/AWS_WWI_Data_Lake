resource "aws_vpc" "My_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_subnet" "subnet_az_1" {
  vpc_id                  = aws_vpc.My_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-sb-${var.availability_zones[0]}"
  }

  depends_on = [aws_vpc.My_vpc]
}

resource "aws_subnet" "subnet_az_2" {
  vpc_id                  = aws_vpc.My_vpc.id
  cidr_block              = "10.0.32.0/24"
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-sb-${var.availability_zones[1]}"
  }

  depends_on = [aws_vpc.My_vpc]
}

resource "aws_subnet" "subnet_az_3" {
  vpc_id                  = aws_vpc.My_vpc.id
  cidr_block              = "10.0.128.0/24"
  availability_zone       = var.availability_zones[2]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-sb-${var.availability_zones[2]}"
  }

  depends_on = [aws_vpc.My_vpc]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.My_vpc.id

  tags = {
    Name = "${var.prefix}-igw"
  }

  depends_on = [aws_vpc.My_vpc]
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.My_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.prefix}-routetable"
  }

  depends_on = [
    aws_internet_gateway.igw,
    aws_subnet.subnet_az_1,
    aws_subnet.subnet_az_2,
    aws_subnet.subnet_az_3
  ]
}

resource "aws_route_table_association" "subnet_az_1" {
  subnet_id      = aws_subnet.subnet_az_1.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "subnet_az_2" {
  subnet_id      = aws_subnet.subnet_az_2.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "subnet_az_3" {
  subnet_id      = aws_subnet.subnet_az_3.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.My_vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids   = [ aws_route_table.public_route.id ]
  vpc_endpoint_type = "Gateway"
  
  tags = {
    name = "${var.prefix}-s3-endpoint"
  }
}