output "private_service_discovery_arn" {
  value = {
    for k, v in var.private_dns_hosts :
    k => aws_service_discovery_service.main[k].arn
  }
}
