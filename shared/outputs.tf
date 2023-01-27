output "main_vpc_id" {
  value = module.vpc.main_vpc_id
}


output "main_vpc_ig_id" {
  value = module.vpc.main_vpc_ig_id
}

output "main_vpc_route_table_id" {
  value = module.vpc.main_vpc_ig_route_table_id
}

output "private_ns_id" {
  value = aws_service_discovery_private_dns_namespace.main.id
}
