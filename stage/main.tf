locals {
  env             = "stage"
  supertokens_app = "supertokens-${local.env}"
  platform_app    = "platform-${local.env}"

  private_dns_namespace = "platform.co"
  supertokens_namespace = "${local.env}.supertokens"

  platform_domain = "alpha.tinkerhub.org"
}

module "secrets" {
  source      = "../modules/secrets"
  environment = local.env
  create_secrets = {
    "supertokens_api_key"     = { type = "SecureString", value = var.supertokens_secrets.api_key }
    "supertokens_pg_uri"      = { type = "SecureString", value = var.supertokens_secrets.pg_uri }
    "platform_pg_uri"         = { type = "SecureString", value = var.platform_secrets.pg_uri }
    "platform_msg91_auth_key" = { type = "SecureString", value = var.platform_secrets.msg91_auth_key }
  }

  load_secrets = [
    "supertokens_api_key",
    "supertokens_pg_uri",
    "platform_pg_uri",
    "platform_msg91_auth_key"
  ]
}

module "network" {
  source         = "../modules/network"
  environment    = local.env
  create_new_vpc = false
  create_ig      = false

  vpc_id = data.terraform_remote_state.shared.outputs.main_vpc_id
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
  ecs_vpc_id  = data.terraform_remote_state.shared.outputs.main_vpc_id
}

module "dns" {
  source = "../modules/dns"

  environment           = local.env
  create_private_dns_ns = false
  private_dns_vpc_id    = data.terraform_remote_state.shared.outputs.main_vpc_id
  private_dns_namespace = local.private_dns_namespace
  private_dns_hosts = {
    "supertokens" = {
      host = local.supertokens_namespace
    }
  }

  enable_ssl         = true
  cloudflare_zone_id = var.cloudflare_zone_id
  public_dns_records = [
    {
      name    = local.platform_domain
      value   = aws_lb.main.dns_name
      type    = "CNAME"
      proxied = true
    }
  ]
}


module "supertokens_iam_role" {
  source = "../modules/role"

  role_type                       = "ecs"
  environment                     = local.env
  attach_ecs_task_policy          = true
  attach_ssm_secret_access_policy = true
  name                            = "ecsSupertokens"
  ssm_secret_arns = [
    module.secrets.ssm_arns["supertokens_pg_uri"],
    module.secrets.ssm_arns["supertokens_api_key"]
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
      { name = "POSTGRESQL_CONNECTION_URI", valueFrom = module.secrets.ssm_arns["supertokens_pg_uri"] },
      { name = "API_KEYS", valueFrom = module.secrets.ssm_arns["supertokens_api_key"] }
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


module "platform_logging" {
  source      = "../modules/logging"
  app_name    = "platform"
  environment = local.env
}


module "platform_iam_role" {
  source = "../modules/role"

  environment                     = local.env
  role_type                       = "ecs"
  attach_ecs_task_policy          = true
  attach_ssm_secret_access_policy = true
  attach_ecs_debug_policy         = true
  name                            = "ecsPlatform"
  ssm_secret_arns = [
    module.secrets.ssm_arns["supertokens_api_key"],
    module.secrets.ssm_arns["platform_pg_uri"],
    module.secrets.ssm_arns["platform_msg91_auth_key"]
  ]
}


data "template_file" "platform" {
  template = file("../modules/containers/task-definitions/platform.json.tpl")

  vars = {
    # Container def vars
    APP_NAME       = local.platform_app
    REPOSITORY_URL = var.platform_container.registry_uri
    CONTAINER_PORT = var.platform_container.container_port
    HOST_PORT      = var.platform_container.host_port

    # Logging
    CLOUDWATCH_LOG_GROUP = module.platform_logging.cloudwatch-ecs.id
    AWS_REGION           = var.aws_region

    SECRETS = jsonencode([
      { name = "DATABASE_URL", valueFrom = module.secrets.ssm_arns["platform_pg_uri"] },
      { name = "SUPERTOKENS_API_KEY", valueFrom = module.secrets.ssm_arns["supertokens_api_key"] },
      { name = "MSG91_AUTH_KEY", valueFrom = module.secrets.ssm_arns["platform_msg91_auth_key"] }
    ])

    CONTAINER_ENVS = jsonencode(var.platform_env)
  }
}


module "platform" {
  source = "../modules/containers"

  name            = local.platform_app
  environment     = local.env
  task_definition = data.template_file.platform.rendered
  cluster_id      = module.ecs.main_cluster_id
  cluster_name    = module.ecs.main_cluster_name
  cpu             = var.platform_container.cpu
  memory          = var.platform_container.memory

  // network and se
  enable_exec_command = var.platform_container.enable_exec_command
  load_balancers = [
    { tg_arn = aws_lb_target_group.main.arn,
      port : var.platform_container.container_port,
      container_name : local.platform_app
    }
  ]
  task_role_iam_role_arn = module.platform_iam_role.role_arn
  exec_iam_role_arn      = module.platform_iam_role.role_arn
  iam_policy_attachment  = module.platform_iam_role.ecs_task_execution_policy
  sg_ids                 = [module.security.platform_sg_id]
  subnets                = module.network.public_subnet_ids
}

resource "aws_lb" "main" {
  name               = "main-reverse-proxy"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.security.main_alb_sg_id]
  subnets            = module.network.public_subnet_ids
}

resource "aws_lb_target_group" "main" {
  name        = "${local.env}-platform"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.terraform_remote_state.shared.outputs.main_vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    protocol            = "HTTP"
    timeout             = "3"
    unhealthy_threshold = "2"

  }
}

resource "aws_lb_listener" "http" {
  port              = 80
  protocol          = "HTTP"
  load_balancer_arn = aws_lb.main.arn

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = module.dns.ssl_certificate_arn[local.platform_domain]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
