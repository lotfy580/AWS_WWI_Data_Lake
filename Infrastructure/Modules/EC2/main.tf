################################################################################
# Generate private/public keys for ec2 instance
################################################################################
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


################################################################################
# Save key.pem file to local machine
################################################################################
resource "local_sensitive_file" "key-file" {
  content  = tls_private_key.ec2_key.private_key_pem
  filename = pathexpand(var.key_save_path)
  file_permission = "600"
  directory_permission = "700"
}

################################################################################
# Create key pair to ssh to instance
################################################################################
resource "aws_key_pair" "kafka_client_key" {
    key_name = "${var.prefix}-KafkaClientKey"
  public_key = tls_private_key.ec2_key.public_key_openssh
}



################################################################################
# Create ec2 instance and execute script which will install kafka client
################################################################################

data "template_file" "user_data" {
  template = "${file(var.installation_script_path)}"

  vars = {
    bootstrap    = "${var.kafka_bootstrap}"
    kafkaversion = "${var.kafka_version}"
  }
}


resource "aws_instance" "Kafka_client_instance" {
  ami             = var.instance_ami 
  
  instance_type   = var.instance_type
  vpc_security_group_ids = [var.security_group_id] 
  iam_instance_profile = aws_iam_instance_profile.kafka_client_iam_profile.name
  key_name = aws_key_pair.kafka_client_key.key_name
  user_data = "${data.template_file.user_data.rendered}"
  subnet_id = var.subnet
  tags = {
    name = "${var.prefix}-kafkaClient"
  }
  depends_on = [ 
    aws_key_pair.kafka_client_key,
    local_sensitive_file.key-file,
    tls_private_key.ec2_key
   ]
}

################################################################################
# Set IAM role for kafka client instance
################################################################################

resource "aws_iam_role" "kafka_client_iam_role" {
  name               = "${var.prefix}-kafkaClientIAMrole"
  description        = "IAM role for kafka client ec2 instance"
  assume_role_policy = file(var.iam_role)
}

################################################################################
# Set IAM Policy for Kafka client instance role
################################################################################

data "template_file" "iam_policy" {
  template = "${file(var.iam_policy)}"

  vars = {
    bucket = "${var.bucket}"
    region = "${var.region}"
    account_id = "${var.account_id}"
    cluster_name = "${var.msk_cluster_name}"
  }
}

resource "aws_iam_policy" "kafka_client_iam_policy" {
  name = "${var.prefix}-kafkaClientIAMpolicy"
  description = "IAM policy to connect to MSK"
  policy = "${data.template_file.iam_policy.rendered}"
}


################################################################################
# Attach Kafka client instance IAM policies to IAM role
################################################################################

resource "aws_iam_role_policy_attachment" "kafka_client_policy_attachment" {
  role = aws_iam_role.kafka_client_iam_role.name
  policy_arn = aws_iam_policy.kafka_client_iam_policy.arn
}

################################################################################
# Create instance profile for kafka client instance
################################################################################

resource "aws_iam_instance_profile" "kafka_client_iam_profile" {
  name = "${var.prefix}-kafkaClientIAMprofile"
  role = aws_iam_role.kafka_client_iam_role.name
}