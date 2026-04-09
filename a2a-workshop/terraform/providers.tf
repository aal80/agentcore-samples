terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.36"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "aws" {}

resource "random_string" "prefix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

locals {
  prefix = random_string.prefix.id
  project_name_short = "a2a-workshop"
  project_name = "${local.prefix}-${local.project_name_short}"
  project_name_underscore = replace(local.project_name, "-","_")
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

