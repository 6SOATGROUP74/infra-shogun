data "archive_file" "lambda_cognito" {
  type        = "zip"
  source_file = "source/lambdacognito.py"
  output_path = "source/lambdacognito.zip"
}

resource "aws_lambda_function" "test_lambda_cognito" {

  filename      = "source/lambdacognito.zip" #lambda_function_payload.zip"
  function_name = "lambda-cognito"
  role          = local.lab_role
  handler       = "lambdacognito.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      cognito_id = aws_cognito_user_pool.pool.id
    }
  }
}