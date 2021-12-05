terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "packet-pigeon-base-infra-terraform-state"
    key = "default-infrastructure"
    region = "eu-west-1"
    profile = "default"
    encrypt = true
  }
}

# AWS
variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_s3_bucket" "base_infra_state_bucket" {
  bucket = "packet-pigeon-base-infra-terraform-state"
  acl    = "private"

  # Tells AWS to encrypt the S3 bucket at rest by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Prevents Terraform from destroying or replacing this object - a great safety mechanism
  lifecycle {
    prevent_destroy = true
  }

  # Tells AWS to keep a version history of the state file
  versioning {
    enabled = true
  }

  tags = {
    Terraform = "true"
  }
}

resource "aws_s3_bucket_public_access_block" "base_infra_state_bucket_access" {
  bucket = aws_s3_bucket.base_infra_state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
