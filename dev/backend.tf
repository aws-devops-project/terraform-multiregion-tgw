terraform {
  backend "s3" {
    bucket         = "terraform-statelock-backend-bucket"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-2"
#    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
