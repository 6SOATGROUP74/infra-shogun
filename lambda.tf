data "archive_file" "lambda" {
  type        = "zip"
  source_file = "source/lambda.py"
  output_path = "source/lambda.zip"
}

resource "aws_lambda_function" "test_lambda" {

  filename      = "source/lambda.zip" 
  function_name = "lambda_function_name"
  role          = local.lab_role
  handler       = "lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      cognito_id = aws_cognito_user_pool.pool.id
    }
  }
}