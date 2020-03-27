provider aws {
  region = "eu-central-1"
}

module ecs {
  source = "./modules"
  cluster_name = "chartmuseum-cluster"
  cloud_logs = "chartmuseum-logs"
  image_name = "chartmuseum"
  image_id = var.ECR_REPO
  port = 8080
  cloud_logs_stream = "chartmuseum-stream"
  svc_name = "chart-svc"
  cluster_id = module.ecs.cluster_id
  s3-bucket-name = var.s3-bucket-name
  dynamodb-name = var.dynamodb-name

}

resource "local_file" "backend-file" {
  content = data.template_file.backend_tf.rendered
  filename = "backend.tf"
}

data "template_file" "backend_tf" {
  template = <<POLICY
 terraform {
     backend "s3" {
       bucket         = "$${bucket}"
       key            = "dev/terraform.tfstate"
       region         = "eu-central-1"
       dynamodb_table = "$${dynamodb}"
       encrypt        = true
   }
 }
POLICY
   vars = {
     bucket = var.s3-bucket-name
     key = "chartmuseum"
     dynamodb = var.dynamodb-name
   }
}
