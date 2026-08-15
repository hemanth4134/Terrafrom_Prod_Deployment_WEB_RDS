# rds.tf

resource "aws_db_instance" "postgres" {
  identifier = "${local.name}-postgres"

  engine         = "postgres"
  engine_version = "16"

  instance_class = var.db_instance_class

  allocated_storage     = 50
  max_allocated_storage = 200
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  port = 5432

  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false

  multi_az = true

  backup_retention_period = 7
  backup_window           = "02:00-03:00"

  maintenance_window = "sun:03:00-sun:04:00"

  auto_minor_version_upgrade = true

  deletion_protection = true

  skip_final_snapshot = false

  final_snapshot_identifier = "${local.name}-final-snapshot"

  copy_tags_to_snapshot = true

  performance_insights_enabled = true

  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade"
  ]

  tags = local.common_tags
}
