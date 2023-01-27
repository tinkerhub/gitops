
locals {
  env = "shared"
}

module "vpc" {
  source = "../modules/network"

  environment    = local.env
  create_new_vpc = true
  create_ig      = true
  vpc_ipv4_cidr  = var.main_vpc_cidr
}

resource "aws_service_discovery_private_dns_namespace" "main" {
  name = var.main_private_namespace
  vpc  = module.vpc.main_vpc_id
}

