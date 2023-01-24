resource "aws_ssm_parameter" "supertokens_api_key" {
  count = var.supertokens_api_key == "" ? 0 : 1

  name        = "/terraform/${var.environment}/SUPERTOKENS_API_KEY"
  description = "Supertoken container api key"
  type        = "SecureString"
  value       = var.supertokens_api_key
}

data "aws_ssm_parameter" "supertokens_api_key" {
  name = "/terraform/${var.environment}/SUPERTOKENS_API_KEY"
  depends_on = [
    aws_ssm_parameter.supertokens_api_key
  ]
}

resource "aws_ssm_parameter" "supertokens_pg_uri" {
  count = var.supertokens_pg_uri == "" ? 0 : 1

  name        = "/terraform/${var.environment}/SUPERTOKENS_PG_URI"
  description = "Supertoken postgres uri"
  type        = "SecureString"
  value       = var.supertokens_pg_uri
}

data "aws_ssm_parameter" "supertokens_pg_uri" {
  name = "/terraform/${var.environment}/SUPERTOKENS_PG_URI"
  depends_on = [
    aws_ssm_parameter.supertokens_pg_uri
  ]
}
