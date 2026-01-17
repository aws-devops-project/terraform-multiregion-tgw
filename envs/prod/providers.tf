terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
  alias  = "london"
}

provider "aws" {
  region = "eu-west-3"
  alias  = "paris"
}
