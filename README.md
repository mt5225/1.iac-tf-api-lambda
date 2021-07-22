# API Gateway with Lambda function

## Supported Features

- Support many of features of HTTP API Gateway, but rather limited support for WebSocket API Gateway
- Conditional creation for many types of resources

## Feature Roadmap

- Some features are still missing (especially for WebSocket support)

## Usage

### HTTP API Gateway

```hcl
module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "dev-http"
  description   = "My awesome HTTP API Gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Custom domain
  domain_name                 = "terraform-aws-modules.modules.tf"
  domain_name_certificate_arn = "arn:aws:acm:eu-west-1:052235179155:certificate/2b3a7ed9-05e1-4f9e-952b-27744ba06da6"

  # Access logs
  default_stage_access_log_destination_arn = "arn:aws:logs:eu-west-1:835367859851:log-group:debug-apigateway"
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  # Routes and integrations
  integrations = {
    "POST /" = {
      lambda_arn             = "arn:aws:lambda:eu-west-1:052235179155:function:my-function"
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }

    "$default" = {
      lambda_arn = "arn:aws:lambda:eu-west-1:052235179155:function:my-default-function"
    }
  }

  tags = {
    Name = "http-apigateway"
  }
}
```

## Conditional creation

Sometimes you need to have a way to create resources conditionally but Terraform does not allow usage of `count` inside `module` block, so the solution is to specify `create` arguments.

```hcl
module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  create = false # to disable all resources

  create_api_gateway               = false  # to control creation of API Gateway
  create_api_domain_name           = false  # to control creation of API Gateway Domain Name
  create_default_stage             = false  # to control creation of "$default" stage
  create_default_stage_api_mapping = false  # to control creation of "$default" stage and API mapping
  create_routes_and_integrations   = false  # to control creation of routes and integrations
  create_vpc_link                  = false  # to control creation of VPC link

  # ... omitted
}
```
