resource "aws_cognito_user_pool" "pool" {
  name = "pool-shogun-lanches"
}

resource "aws_cognito_resource_server" "resource" {
  identifier = "https://example.com"
  name       = "example"

  scope {
    scope_name        = "sample-scope"
    scope_description = "a Sample Scope Description"
  }

  user_pool_id = aws_cognito_user_pool.pool.id
}


resource "aws_cognito_user" "cognito_users" {
  user_pool_id = aws_cognito_user_pool.pool.id
  username     = "48265391854"
}