# variables.tf

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "production-web"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)

  default = [
    "eu-west-2a",
    "eu-west-2b"
  ]
}

variable "container_image" {
  description = "Docker image for the application"
  type        = string
}

variable "container_port" {
  description = "Application container port"
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Initial ECS desired count"
  type        = number
  default     = 2
}

variable "cpu" {
  description = "ECS CPU units"
  type        = number
  default     = 512
}

variable "memory" {
  description = "ECS memory in MB"
  type        = number
  default     = 1024
}

variable "db_name" {
  type      = string
  default   = "appdb"
  sensitive = true
}

variable "db_username" {
  type      = string
  default   = "appadmin"
  sensitive = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.medium"
}

variable "log_retention_days" {
  type    = number
  default = 30
}
