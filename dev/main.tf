
locals {
  env             = "dev"
  supertokens_app = "supertokens-stage"
  platform_app    = "platform-${local.env}"

  supertokens_namespace = "stage.supertokens"
}

module "secrets" {
  source      = "../modules/secrets"
  environment = local.env
  create_secrets = {
    "supertokens_api_key"     = { type = "SecureString", value = var.supertokens_secrets.api_key }
    "platform_pg_uri"         = { type = "SecureString", value = var.platform_secrets.pg_uri }
    "platform_msg91_auth_key" = { type = "SecureString", value = var.platform_secrets.msg91_auth_key }
  }

  load_secrets = [
    "supertokens_api_key",
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
    cidr = "10.0.176.0/20"
    }, {
    az   = "${var.aws_region}b"
    cidr = "10.0.192.0/20"
  }]

  private_subnets = [{
    az   = "${var.aws_region}a"
    cidr = "10.0.208.0/20"
    }, {
    az   = "${var.aws_region}b"
    cidr = "10.0.224.0/20"
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
  private_dns_namespace = data.terraform_remote_state.shared.outputs.private_ns_name

  enable_ssl         = true
  cloudflare_zone_id = var.cloudflare_zone_id
  public_dns_records = [
    {
      name    = var.platform_domain
      value   = data.terraform_remote_state.stage.outputs.reverse_proxy_alb_dns_name
      type    = "CNAME"
      proxied = true
    }
  ]
}


module "platform_logging" {
  source      = "../modules/logging"
  app_name    = "platform"
  environment = local.env
}

data "aws_security_group" "stage_platform" {
  name = "stage-platform"
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

    CONTAINER_ENVS = jsonencode(concat(var.platform_env,
      [
        { name = "SUPERTOKENS_URI", value = "http://${local.supertokens_namespace}.${data.terraform_remote_state.shared.outputs.private_ns_name}:3567" },
        { name = "APP_NAME", value = "platform" },
        { name = "SUPERTOKENS_API_DOMAIN", value = var.platform_domain },
        { name = "SUPERTOKENS_WEBSITE_DOMAIN", value = var.platform_website_domain },
        { name = "SUPERTOKENS_PATH", value = "/auth" },
    ]))
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
    { 
			tg_arn = aws_lb_target_group.reverse_proxy.arn,
      port : var.platform_container.container_port,
      container_name : local.platform_app
    }
  ]
  task_role_iam_role_arn = module.platform_iam_role.role_arn
  exec_iam_role_arn      = module.platform_iam_role.role_arn
  iam_policy_attachment  = module.platform_iam_role.ecs_task_execution_policy
  sg_ids                 = [data.aws_security_group.stage_platform.id,module.security.platform_sg_id]
  subnets                = module.network.public_subnet_ids
}

// reverse proxy settings
resource "aws_lb_target_group" "reverse_proxy" {
  name        = "${local.env}-alb-main-tg"
  target_type = "ip"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.shared.outputs.main_vpc_id
}

resource "aws_lb_listener_certificate" "main" {
  listener_arn    = data.terraform_remote_state.stage.outputs.reverse_proxy_listener_arn["https"]
  certificate_arn = module.dns.ssl_certificate_arn[var.platform_domain]
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = data.terraform_remote_state.stage.outputs.reverse_proxy_listener_arn["http"]

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = [var.platform_domain]
    }
  }
}

resource "aws_lb_listener_rule" "https" {
  listener_arn = data.terraform_remote_state.stage.outputs.reverse_proxy_listener_arn["https"]

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.reverse_proxy.arn
  }

  condition {
    host_header {
      values = [var.platform_domain]
    }
  }
}

