resource "aws_dynamodb_table" "dynamo-versions" {
  name           = "versions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "service-name"

  attribute {
    name = "service-name"
    type = "S"
  }
}