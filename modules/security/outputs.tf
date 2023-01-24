output "supertokens_sg_id" {
  value = aws_security_group.supertokens_ecs.id
}

output "platform_lamda_sg_id" {
  value = aws_security_group.platform_lambda.id
}
