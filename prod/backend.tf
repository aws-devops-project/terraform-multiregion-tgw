terraform {
  backend "s3" {
    bucket         = "terraform-statelock-backend-bucket"
    key            = "prod/terraform.tfstate"
    region         = "eu-west-2"
#    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
