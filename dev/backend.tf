terraform {
  backend "s3" {
    bucket         = "terraform-statelock-backend-bucket-dr"
    key            = "prod/london/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}