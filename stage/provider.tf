terraform {

  backend "s3" {
    bucket = "tinkerhub-terraform-state"
    key    = "environments/stagev2/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {

    // aws s3 state sync
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
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

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
  name = "terraform"
}
