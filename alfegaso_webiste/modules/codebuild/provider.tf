terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6"
    }
  }
}
data "aws_iam_policy_document" "codebuild_assume_rol" {
  statement {
    sid = "AllowCodebuildAssumeRole"
    effect = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      type = "Service"
      identifiers = [ "codebuild.amazonaws.com" ]
    }
  }
}
data "aws_iam_policy_document" "codebuild" {
  statement {
    sid = "S3WebsiteBucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      "${var.bucket_arn}",
      "${var.bucket_arn}/*"
    ]
  }
  statement {
    sid = "GitHubConnection"
    effect = "Allow"
    actions = [
      "codeconnections:GetConnectionToken",
      "codeconnections:GetConnection",
      "codeconnections:UseConnection"
      ]
      resources = [aws_codestarconnections_connection.this.arn]
  }
  
}

resource "aws_codestarconnections_connection" "this" {
   name = "${var.github_organization}-${var.environment}"
   provider_type = "GitHub"
}

resource "aws_iam_role_policy" "codebuild_permissions" {
  name = "${var.environment}-codebuild-permissions"
  policy = data.aws_iam_policy_document.codebuild.json
  role = aws_iam_role.codebuild.name
}

resource "aws_iam_role" "codebuild" {
    name = "codebuild-${var.github_organization}-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_rol.json
  
}

resource "aws_codebuild_webhook" "development" {
  project_name = aws_codebuild_project.this.name
  build_type   = "BUILD"

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "^refs/heads/${var.environment}$"
    }
  }
}
resource "aws_codebuild_project" "this" {
  name          = "codebuild-${var.github_organization}-${var.environment}-${var.github_repository}"
  service_role = aws_iam_role.codebuild.arn
  build_timeout = 5
  source_version = var.branch_name
  tags = {
    environment = var.environment,
    organization = var.github_organization,
  }
  
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
    environment_variable {
      name  = "S3_BUCKET_NAME"
      value = var.bucket_name
      type ="PLAINTEXT"
    }

  }
  source {
    
    type = "GITHUB"
    location = "https://github.com/${var.github_organization}/${var.github_repository}"
    buildspec = ".devops/${var.environment}/buildspecs.yml"
    
    auth {
      type = "CODECONNECTIONS"
      resource = aws_codestarconnections_connection.this.arn
    }
}

artifacts {
    type = "NO_ARTIFACTS"
  }

}