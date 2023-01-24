locals {
  ns_id = try(aws_service_discovery_private_dns_namespace.main[0].id,
  data.aws_service_discovery_dns_namespace.main[0].id)
}

resource "aws_service_discovery_private_dns_namespace" "main" {
  count = var.create_private_dns_ns ? 1 : 0

  name = var.private_dns_namespace
  vpc  = var.private_dns_vpc_id
}

data "aws_service_discovery_dns_namespace" "main" {
  count = !var.create_private_dns_ns && var.private_dns_namespace != null ? 1 : 0

  name = var.private_dns_namespace
  type = "DNS_PRIVATE"
}

resource "aws_service_discovery_service" "main" {
  for_each = var.private_dns_hosts

  name = each.value.host

  dns_config {
    namespace_id   = local.ns_id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 60
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 5
  }
}
