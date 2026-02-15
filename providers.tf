terraform {
  required_version = ">= 1.5.0" #Terraform 1.14+ and AWS Provider 6.x are currently available).

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
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
provider "aws" {
  region = "eu-west-1"
  alias  = "dr"
}