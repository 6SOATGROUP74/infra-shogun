terraform {
  backend "s3" {
    bucket = "backend-terraform-shogun"
    key = "gateway/terraform.tfstate"
    region = "us-east-1"
  }
}