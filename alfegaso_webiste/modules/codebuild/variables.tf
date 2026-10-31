variable "environment" {
  type = string
  description = "The environment where the infastructure will run"
}

variable "github_organization" {
  type = string
  description = "The name of the Github Organization"
}

variable "github_repository" {
  type = string
  description = "The name of the Github Repository"
}

variable "bucket_arn" {
  type = string
  description = "The ARN of the S3 bucket"
}
variable "bucket_name" {
  type = string
  description = "The name of the S3 bucket"
}

variable "branch_name" {
  type = string
  description = "The branch where the build will be triggered."
}