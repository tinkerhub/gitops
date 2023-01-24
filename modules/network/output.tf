output "main_vpc_id" {
  value = local.vpc_id
}

output "main_vpc_ig_id" {
  value = local.ig_id
}

output "main_vpc_ig_route_table_id" {
  value = try(aws_route_table.main[0].id, data.aws_route_table.main[0].id)
}

output "public_subnet_ids" {
  value = length(aws_subnet.public) == 0 ? [] : values(aws_subnet.public).*.id
}

output "private_subnet_ids" {
  value = length(aws_subnet.private) == 0 ? [] : values(aws_subnet.private).*.id
}
