locals {
  secrets = {
    for secret_name, data in var.create_secrets :
    secret_name => {
      description : data.description,
      type : data.type,
      value : sensitive(data.value)
    } if data.value != ""
  }
}

resource "aws_ssm_parameter" "main" {
  for_each = nonsensitive(toset(keys(local.secrets)))

  name        = "/terraform/${var.environment}/${each.key}"
  description = local.secrets[each.key].description
  type        = local.secrets[each.key].type
  value       = local.secrets[each.key].value

}

data "aws_ssm_parameter" "main" {
  depends_on = [aws_ssm_parameter.main]

  for_each = var.load_secrets
  name     = "/terraform/${var.environment}/${each.key}"
}
