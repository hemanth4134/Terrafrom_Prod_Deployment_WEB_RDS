# terraform.tfvars

aws_region   = "eu-west-2"
project_name = "my-web-service"
environment  = "prod"

container_image = "123456789012.dkr.ecr.eu-west-2.amazonaws.com/my-web-service:1.0.0"

container_port = 8080

desired_count = 2

cpu    = 512
memory = 1024

db_name     = "application"
db_username = "appadmin"

db_instance_class = "db.t4g.medium"

acm_certificate_arn = "arn:aws:acm:eu-west-2:123456789012:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
