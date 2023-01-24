resource "aws_ecs_cluster" "main_cluster" {
  name = var.environment
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main_cluster.name

  capacity_providers = var.environment == "prod" ? ["FARGATE_SPOT", "FARGATE"] : ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }
}