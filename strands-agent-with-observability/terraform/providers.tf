terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.36"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.75"
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

provider "awscc" {}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "random_string" "prefix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

locals {
  prefix = random_string.prefix.id
  project_name = "strands-agent-with-observability"
}