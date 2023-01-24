output "supertokens_api_key_ssm_arn" {
  value = data.aws_ssm_parameter.supertokens_api_key.arn
}

output "supertokens_pg_uri_ssm_arn" {
  value = data.aws_ssm_parameter.supertokens_pg_uri.arn
}
