resource "aws_api_gateway_vpc_link" "dev_tmng_api_gateway_vpc_link" {
  name        = "${local.namespace}"
  description = "allows public API Gateway for ${local.namespace} to talk to private NLB"
  target_arns = [aws_lb.dev_tmng_api_gateway_nlb.arn]
}

resource "aws_api_gateway_rest_api" "dev_tmng_rest_api_gateway" {
  name = local.namespace

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "dev_tmng_api_gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.dev_tmng_rest_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.dev_tmng_rest_api_gateway.root_resource_id
  path_part   = "TMNG"
}

resource "aws_api_gateway_method" "dev_tmng_api_gateway_method" {
  rest_api_id      = aws_api_gateway_rest_api.dev_tmng_rest_api_gateway.id
  resource_id      = aws_api_gateway_resource.dev_tmng_api_gateway_resource.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = false
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "dev_tmng_api_gateway_integration" {
  rest_api_id = aws_api_gateway_rest_api.dev_tmng_rest_api_gateway.id
  resource_id = aws_api_gateway_resource.dev_tmng_api_gateway_resource.id
  http_method = aws_api_gateway_method.dev_tmng_api_gateway_method.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${aws_lb.dev_tmng_api_gateway_nlb.dns_name}/TMNG"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.dev_tmng_api_gateway_vpc_link.id
  timeout_milliseconds    = 29000 # 50-29000

  cache_key_parameters = ["method.request.path.proxy"]
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_method_response" "dev_tmng_api_gateway_method_response" {
  rest_api_id = aws_api_gateway_rest_api.dev_tmng_rest_api_gateway.id
  resource_id = aws_api_gateway_resource.dev_tmng_api_gateway_resource.id
  http_method = aws_api_gateway_method.dev_tmng_api_gateway_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "dev_tmng_api_gateway_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.dev_tmng_rest_api_gateway.id
  resource_id = aws_api_gateway_resource.dev_tmng_api_gateway_resource.id
  http_method = aws_api_gateway_method.dev_tmng_api_gateway_method.http_method
  status_code = aws_api_gateway_method_response.dev_tmng_api_gateway_method_response.status_code

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_deployment" "dev_tmng_api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.dev_tmng_rest_api_gateway.id
  stage_name  = "dev"
}

# resource "aws_api_gateway_base_path_mapping" "dev_tmng_api_gateway_base_path_mapping" {
#   api_id      = aws_api_gateway_rest_api.dev_tmng_rest_api_gateway.id
#   stage_name  = aws_api_gateway_deployment.dev_tmng_api_gateway_deployment.stage_name
#   domain_name = aws_api_gateway_domain_name.main.domain_name
# }

resource "aws_api_gateway_usage_plan" "dev_tmng_api_gateway_usage_plan" {
  name        = local.namespace
  description = "default usage plan for ${local.namespace}"

  api_stages {
    api_id = aws_api_gateway_rest_api.dev_tmng_rest_api_gateway.id
    stage  = aws_api_gateway_deployment.dev_tmng_api_gateway_deployment.stage_name
  }

  quota_settings {
    limit  = var.api_usage_quota_limit
    offset = var.api_usage_quota_offset
    period = var.api_usage_quota_period
  }

  throttle_settings {
    burst_limit = var.api_usage_burst_limit
    rate_limit  = var.api_usage_rate_limit
  }
}