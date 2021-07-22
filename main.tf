
### Lambda
module "acmelambda" {
  source = "./modules/terraform-aws-lambda-master"

  function_name  = "acmelambda"
  description    = "acme lambda function"
  handler        = "main.lambda_handler"
  runtime        = "python3.8"
  create_package = false
  s3_existing_package = {
    bucket = "mt5225-tf-lambda"
    key    = "main.zip"
  }
}



### log group
module "acmelog" {
  source = "./modules/aws-cloudwatch-log"
  name   = "acmelog"
  tags = {
    Name = "acmelog"
    Role = "apigw-log"
  }
}

### API gateway
module "acmeapigw" {
  source = "./modules/terraform-aws-apigateway-v2"

  name          = "acme-apigw"
  description   = "Acme HTTP API Gateway"
  protocol_type = "HTTP"
  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }
  create_api_gateway               = true  # to control creation of API Gateway
  create_api_domain_name           = false # to control creation of API Gateway Domain Name
  create_default_stage             = true  # to control creation of "$default" stage
  create_default_stage_api_mapping = true  # to control creation of "$default" stage and API mapping
  create_routes_and_integrations   = true

  # Access logs
  default_stage_access_log_destination_arn = module.acmelog.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"


  # Routes and integrations
  integrations = {
    "ANY /" = {
      lambda_arn = module.acmelambda.lambda_function_arn
    }
  }

  tags = {
    Name = "http-apigateway"
    Role = "acme-apigw"
  }

}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.acmelambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:apigateway:us-west-2::/apis/*"
}

output "gw_url" {
  value = module.acmeapigw.apigatewayv2_api_api_endpoint
}
