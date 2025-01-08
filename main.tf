terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "rumo-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}