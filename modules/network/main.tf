locals {
  vpc_id = try(aws_vpc.main[0].id, var.vpc_id)
  ig_id  = try(aws_internet_gateway.main[0].id, data.aws_internet_gateway.main[0].id)
}

resource "aws_vpc" "main" {
  count = var.create_new_vpc ? 1 : 0

  cidr_block           = var.vpc_ipv4_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Env = var.environment
  }
}

resource "aws_internet_gateway" "main" {
  count  = var.create_ig ? 1 : 0
  vpc_id = local.vpc_id
}

data "aws_internet_gateway" "main" {
  count = !var.create_ig ? 1 : 0

  filter {
    name   = "attachment.vpc-id"
    values = [local.vpc_id]
  }
}

resource "aws_subnet" "public" {
  for_each = {
    for index, val in var.public_subnets :
    val.cidr => val
  }

  vpc_id                  = local.vpc_id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  for_each = {
    for index, val in var.private_subnets :
    val.cidr => val
  }

  vpc_id                  = local.vpc_id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false
}

resource "aws_route_table" "main" {
  count = var.create_new_vpc && var.create_ig ? 1 : 0

  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.ig_id
  }

  tags = {
    Type = "ig-route-table"
  }
}

data "aws_route_table" "main" {
  count = !var.create_ig ? 1 : 0

  vpc_id = local.vpc_id

  filter {
    name   = "tag:Type"
    values = ["ig-route-table"]
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = try(aws_route_table.main[0].id, data.aws_route_table.main[0].id)
}

