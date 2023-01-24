locals {
  env             = "prod"
  supertokens_app = "supertokens-${local.env}"

  private_dns_namespace = "platform.co"
  supertokens_namespace = "${local.env}.supertokens"
}

module "secrets" {
  source              = "../modules/secrets"
  environment         = local.env
  supertokens_api_key = var.supertokens_secrets.api_key
  supertokens_pg_uri  = var.supertokens_secrets.pg_uri
}

module "network" {
  source = "../modules/network"

  environment    = local.env
  create_new_vpc = true
  create_ig      = true
  vpc_ipv4_cidr  = "10.0.0.0/16"
  public_subnets = [{
    az   = "${var.aws_region}a"
    cidr = "10.0.160.0/20"
    }, {
    az   = "${var.aws_region}b"
    cidr = "10.0.176.0/20"
  }]

  private_subnets = [{
    az   = "${var.aws_region}a"
    cidr = "10.0.128.0/20"
    }, {
    az   = "${var.aws_region}b"
    cidr = "10.0.144.0/20"
  }]
}


module "ecs" {
  source      = "../modules/ecs"
  environment = local.env
}

module "security" {
  source      = "../modules/security"
  environment = local.env
  ecs_vpc_id  = module.network.main_vpc_id
}

module "dns" {
  source = "../modules/dns"

  environment           = local.env
  create_private_dns_ns = true
  private_dns_vpc_id    = module.network.main_vpc_id
  private_dns_namespace = local.private_dns_namespace
  private_dns_hosts = {
    "supertokens" = {
      host = local.supertokens_namespace
    }
  }
}


module "supertokens_iam_role" {
  source = "../modules/role"

  role_type                       = "ecs"
  environment                     = local.env
  attach_ecs_task_policy          = true
  attach_ssm_secret_access_policy = true
  name                            = "ecsSupertokens"
  ssm_secret_arns = [
    module.secrets.supertokens_api_key_ssm_arn,
    module.secrets.supertokens_pg_uri_ssm_arn
  ]
}

module "supertokens_logging" {
  source      = "../modules/logging"
  app_name    = "supertokens"
  environment = local.env
}

data "template_file" "supertokens_task_def" {
  template = file("../modules/containers/task-definitions/supertokens.json.tpl")

  vars = {
    # Container def vars
    APP_NAME       = local.supertokens_app
    REPOSITORY_URL = var.supertokens_container.registry_uri
    CONTAINER_PORT = var.supertokens_container.container_port
    HOST_PORT      = var.supertokens_container.host_port

    # Logging
    CLOUDWATCH_LOG_GROUP = module.supertokens_logging.cloudwatch-ecs.id
    AWS_REGION           = var.aws_region

    SECRETS = jsonencode([
      { name = "POSTGRESQL_CONNECTION_URI", valueFrom = module.secrets.supertokens_pg_uri_ssm_arn },
      { name = "API_KEYS", valueFrom = module.secrets.supertokens_api_key_ssm_arn }
    ])
  }
}

module "supertokens" {
  source = "../modules/containers"

  name            = local.supertokens_app
  environment     = local.env
  task_definition = data.template_file.supertokens_task_def.rendered
  cluster_id      = module.ecs.main_cluster_id
  cluster_name    = module.ecs.main_cluster_name
  cpu             = var.supertokens_container.cpu
  memory          = var.supertokens_container.memory

  // network and se
  enable_exec_command   = var.supertokens_container.enable_exec_command
  exec_iam_role_arn     = module.supertokens_iam_role.role_arn
  iam_policy_attachment = module.supertokens_iam_role.ecs_task_execution_policy
  sg_ids                = [module.security.supertokens_sg_id]
  subnets               = module.network.public_subnet_ids
  service_discovery_arn = module.dns.private_service_discovery_arn["supertokens"]
}
