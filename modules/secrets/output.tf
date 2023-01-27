output "ssm_arns" {
  value = {
    for k, v in data.aws_ssm_parameter.main : k => v.arn
  }
}
