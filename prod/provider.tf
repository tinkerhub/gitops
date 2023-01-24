terraform {

  backend "s3" {
    bucket = "tinkerhub-terraform-state"
    key    = "environments/prod/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = {
      Owner = "akhilmhdh"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
