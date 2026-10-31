terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
  }
}
module "codebuild" {
  source              = "../../modules/codebuild"
  environment         = "development"
  bucket_arn          = module.s3.bucket_arn
  github_organization = "aldogallegosr"
  github_repository   = "alfegaso-web-site"
  bucket_name         = module.s3.bucket_name
  branch_name         = "development"
}
module "s3" {
  source       = "../../modules/s3"
  environment  = "development"
  region       = "us-east-1"
  organization = "alfegaso"
}
