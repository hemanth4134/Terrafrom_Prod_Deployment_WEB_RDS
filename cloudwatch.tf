# cloudwatch.tf

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.name}"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}
