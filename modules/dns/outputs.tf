output "private_service_discovery_arn" {
  value = {
    for k, v in var.private_dns_hosts :
    k => aws_service_discovery_service.main[k].arn
  }
}

output "ssl_certificate_arn" {
  value = {
    for k, v in aws_acm_certificate.main :
    v.domain_name => v.arn
  }

  depends_on = [
    aws_acm_certificate_validation.cf_validation
  ]
}
