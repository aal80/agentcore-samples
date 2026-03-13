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

resource "random_string" "prefix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  prefix = random_string.prefix.id
  project_name = "empty-shell-with-flask"
}