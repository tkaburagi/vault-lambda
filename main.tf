# Variables
variable "aws_region" {
  default = "ap-northeast-1"
}

variable "environment_name" {
  default = "kabu-lambda-extension-demo"
}

variable "vault_addr" {
  default = "http://127.0.0.1:8200"
}

# Output
output "lambda_arn" {
  value = aws_iam_role.lambda.arn
}

# Provider
provider "aws" {
  // Credentials set via env vars
  region = var.aws_region
}

# Vault Client (Lambda function) IAM Config
resource "aws_iam_instance_profile" "lambda" {
  name = "${var.environment_name}-lambda-instance-profile"
  role = aws_iam_role.lambda.name
}

resource "aws_iam_role" "lambda" {
  name               = "${var.environment_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
}

resource "aws_iam_role_policy" "lambda" {
  name   = "${var.environment_name}-lambda-policy"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda.json
}

//--------------------------------------------------------------------
// Data Sources

data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda" {
  statement {
    sid    = "LambdaLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

# Lambda
resource "aws_lambda_function" "function" {
  function_name = "${var.environment_name}-function"
  description   = "Demo Vault AWS Lambda extension"
  role          = aws_iam_role.lambda.arn
  filename      = "node.zip"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  layers        = ["arn:aws:lambda:${var.aws_region}:634166935893:layer:vault-lambda-extension:6"]

  environment {
    variables = {
      VAULT_ADDR            = var.vault_addr
      VAULT_AUTH_ROLE       = aws_iam_role.lambda.name,
      VAULT_AUTH_PROVIDER   = "aws",
      VAULT_SECRET_PATH_AWS = "aws/creds/read-s3",
      VAULT_SECRET_FILE_AWS = "/tmp/vault_secret.json",
      VAULT_NAMESPACE       = "admin"
    }
  }
}