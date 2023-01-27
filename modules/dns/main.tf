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

// public dns records with cloudflare

resource "cloudflare_record" "main" {
  for_each = {
    for k, v in var.public_dns_records :
    v.name => v
  }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  value   = each.value.value
  type    = each.value.type
  proxied = each.value.proxied
}

resource "aws_acm_certificate" "main" {
  for_each = cloudflare_record.main

  domain_name               = each.value.name
  subject_alternative_names = ["www.${each.value.name}"]
  validation_method         = var.ssl_validation_method

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Terraform = true
  }
}

locals {
  ssl_domain_validation_records = merge([
    for k, cert in aws_acm_certificate.main : {
      for dvo in cert.domain_validation_options : dvo.domain_name => {
        name   = dvo.resource_record_name
        record = dvo.resource_record_value
        type   = dvo.resource_record_type
      }
    }
  ]...)
}

resource "cloudflare_record" "ssl_records" {
  depends_on = [
    aws_acm_certificate.main
  ]

  for_each = local.ssl_domain_validation_records

  zone_id         = var.cloudflare_zone_id
  allow_overwrite = true
  proxied         = false
  name            = each.value.name
  type            = each.value.type
  value           = each.value.record
  ttl             = 60
}

resource "aws_acm_certificate_validation" "cf_validation" {
  for_each = aws_acm_certificate.main

  certificate_arn         = each.value.arn
  validation_record_fqdns = [for record in cloudflare_record.ssl_records : record.hostname]
}

