resource "aws_api_gateway_authorizer" "demo" {
  name                   = "demo"
  rest_api_id            = aws_api_gateway_rest_api.demo.id
  identity_source        = "method.request.header.Documento"
  authorizer_uri         = aws_lambda_function.lambda_auth.invoke_arn
  authorizer_credentials = "arn:aws:iam::410052166411:role/LabRole"
  type                   = "REQUEST"
}

resource "aws_api_gateway_resource" "MyDemoResource" {
  rest_api_id = aws_api_gateway_rest_api.demo.id
  parent_id   = aws_api_gateway_rest_api.demo.root_resource_id
  path_part   = "mydemoresource"
}

resource "aws_api_gateway_method" "MyDemoMethod" {
  rest_api_id   = aws_api_gateway_rest_api.demo.id
  resource_id   = aws_api_gateway_resource.MyDemoResource.id
  http_method   = "GET"
  authorization = "NONE"
}

data "template_file" "user_api_swagger" {
  template = file("source/swagger/swagger.yaml")
}


resource "aws_api_gateway_rest_api" "demo" {
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
  role             = "arn:aws:iam::410052166411:role/LabRole"
  handler          = "lambda.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("source/lambda.zip")

  environment {
    variables = {
      cognito_id = aws_cognito_user_pool.pool.id
    }
  }

}