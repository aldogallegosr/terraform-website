variable "environment" {
  type = string
  description = "The environment where the infastructure will run"
}

variable "region" {
  type = string
  description = "The AWS region where the S3 bucket will be created"
}

variable "organization" {
  type = string
  description = "The name of the Organization"
}