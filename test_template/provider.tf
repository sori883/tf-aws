provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.profile}"
  default_tags {
    tags = {
      iac = "true"
    }
  }
}

terraform {
  required_version = ">= 1.11.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.12.0"
    }
  }
}