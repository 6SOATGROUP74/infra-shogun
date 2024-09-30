data "template_file" "user_api_swagger" {
  template = file("source/swagger/swagger.yaml")
}


resource "aws_api_gateway_rest_api" "this" {
  name = "auth-demo"
  body = data.template_file.user_api_swagger.rendered
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

data "aws_iam_policy_document" "invocation_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}



resource "aws_lambda_function" "lambda_auth" {
  filename         = "source/lambda.zip"
  function_name    = "lambda_api_gateway_auth"
  role             = local.lab_role
  handler          = "lambda.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("source/lambda.zip")

  environment {
    variables = {
      cognito_id = aws_cognito_user_pool.pool.id
    }
  }

}


resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "shogun"
}