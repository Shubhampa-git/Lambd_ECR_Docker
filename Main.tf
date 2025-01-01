provider "aws" {
  region = "ap-south-1"
}

# IAM Role for Lambda with ECR and CloudWatch Permissions
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role_with_ecr_and_cloudwatch"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for ECR Full Access
resource "aws_iam_policy" "ecr_policy" {
  name        = "ecr_policy"
  description = "ECR full access policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# IAM Policy for CloudWatch Full Access
resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "cloudwatch_policy"
  description = "CloudWatch full access policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach ECR and CloudWatch Policies to Lambda Role
resource "aws_iam_role_policy_attachment" "attach_ecr_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

# Create ECR Repository
resource "aws_ecr_repository" "my_repository" {
  name = "my-docker-repo"
}

# Lambda Function using Docker Image from ECR
resource "aws_lambda_function" "my_lambda" {
  depends_on = [aws_ecr_repository.my_repository]

  function_name = "MyLambdaFunction"

  role = aws_iam_role.lambda_role.arn

  package_type = "Image"
  image_uri    = "054037126982.dkr.ecr.ap-south-1.amazonaws.com/my-docker-repo:latest"

  timeout     = 60
  memory_size = 128
}

# CloudWatch Event Rule to Trigger Lambda Every Minute
resource "aws_cloudwatch_event_rule" "every_minute" {
  name                = "run_lambda_every_minute"
  schedule_expression = "rate(1 minute)"
}

# CloudWatch Event Target to Invoke Lambda
resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.every_minute.name
  arn       = aws_lambda_function.my_lambda.arn
}

# Allow CloudWatch to Trigger Lambda Function
resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_minute.arn
}
