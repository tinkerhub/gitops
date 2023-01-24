resource "aws_cloudwatch_log_group" "ecs" {
  name = "${var.app_name}-log-group-${var.environment}"

  tags = {
    Env         = var.environment
    Application = var.app_name
  }
}
