resource "aws_ecr_repository" "ecr_repository" {
  name = "${var.prefix}-ecr-registry"
  force_delete = true
}


resource "null_resource" "ecr_login" {
  
  provisioner "local-exec" {
    command = <<EOT
    aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com
    EOT
  }
  depends_on = [ aws_ecr_repository.ecr_repository ]
}

resource "null_resource" "build_image" {
  
  provisioner "local-exec" {
    command = <<EOT
    docker build -f ${var.dockerfile_path} -t ${aws_ecr_repository.ecr_repository.name} .
    EOT
  }
  depends_on = [ null_resource.ecr_login ]
}

resource "null_resource" "tag_image" {
  
  provisioner "local-exec" {
    command = <<EOT
    docker tag ${aws_ecr_repository.ecr_repository.name}:latest ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr_repository.name}:latest
    EOT
    
  }
  depends_on = [ null_resource.build_image ]
}

resource "null_resource" "push_image" {
  
  provisioner "local-exec" {
    command = <<EOT
    docker push ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr_repository.name}:latest
    EOT
    
  }
  depends_on = [ null_resource.tag_image ]
}