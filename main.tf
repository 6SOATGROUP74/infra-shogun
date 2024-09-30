terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.66.0"
    }
  }
}

provider "aws" {
  region = local.region
}