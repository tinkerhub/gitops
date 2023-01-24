output "role_arn" {
  value = aws_iam_role.main.arn
}

output "ecs_task_execution_policy" {
  value = try(aws_iam_role_policy_attachment.ecs_task_execution[0], "")
}

output "ecs_debug_policy" {
  value = try(aws_iam_role_policy_attachment.ecs_ssm[0], "")
}
