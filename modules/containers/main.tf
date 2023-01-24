resource "aws_ecs_task_definition" "main" {
  container_definitions    = var.task_definition
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  family                   = var.name
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.exec_iam_role_arn
  task_role_arn            = var.task_role_iam_role_arn
}

resource "aws_ecs_service" "main" {
  name                   = var.name
  enable_execute_command = var.enable_exec_command
  cluster                = var.cluster_id
  task_definition        = aws_ecs_task_definition.main.arn
  desired_count          = var.service_count
  launch_type            = "FARGATE"
  depends_on = [
    var.iam_policy_attachment
  ]

  network_configuration {
    security_groups  = var.sg_ids
    assign_public_ip = var.assign_public_ip
    subnets          = var.subnets
  }

  dynamic "load_balancer" {
    for_each = var.load_balancers
    content {
      container_name   = try(load_balancer.value.container_name, var.name)
      container_port   = load_balancer.value.port
      target_group_arn = load_balancer.value.tg_arn
    }
  }

  dynamic "service_registries" {
    for_each = var.service_discovery_arn == null ? [] : [var.service_discovery_arn]
    content {
      registry_arn = var.service_discovery_arn
    }
  }
}
