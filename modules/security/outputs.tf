output "supertokens_sg_id" {
  value = aws_security_group.supertokens_ecs.id
}

output "platform_sg_id" {
  value = aws_security_group.platform.id
}

output "main_alb_sg_id" {
  value = aws_security_group.main_alb.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}
