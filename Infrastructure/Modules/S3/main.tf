################################################################################
# Create a S3 bucket  
################################################################################

resource "aws_s3_bucket" "create_s3_buckets" {
  bucket        = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = var.s3_bucket_name
  rule {
    object_ownership = "ObjectWriter"
  }
  depends_on = [ aws_s3_bucket.create_s3_buckets ]
}

################################################################################
# Set acl for buckets 
################################################################################

resource "aws_s3_bucket_acl" "bucket_acl" {
 bucket = var.s3_bucket_name
 acl = "private"
 depends_on = [ aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership ]
}

################################################################################
# Configure storage lifcycle manegment for S3 bucket
################################################################################

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_of_buckets" {
 bucket = var.s3_bucket_name
 rule {
   id = "archive"
   expiration {
     days = 90
   }
   status = "Enabled"
   transition {
     days = 30
     storage_class = "STANDARD_IA"
   }
   transition {
     days = 60
     storage_class = "GLACIER"
   }
 }
 
 depends_on = [ aws_s3_bucket.create_s3_buckets ]
}

################################################################################
# upload assets to s3 bucket
################################################################################
resource "null_resource" "upload_assets_s3" {
  provisioner "local-exec" {
    command = <<EOL
    python ${var.uploud_script}
    EOL 
    environment = {
      assets_dir_path = var.assets_path
      bucket_name     = var.s3_bucket_name
    }
  }

  depends_on = [ aws_s3_bucket.create_s3_buckets ]
}
