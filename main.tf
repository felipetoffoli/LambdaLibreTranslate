# 🚀 Configuração do Provedor AWS
provider "aws" {
  region  = var.aws_region
  profile = var.aws_sso_profile
}

# 🔐 Criar a Role para a AWS Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "LambdaLibreTranslateRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 🛡️ Anexar permissões básicas de execução para a Lambda
resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "LambdaBasicExecution"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ⚡ Criar a Função AWS Lambda baseada em Container (Docker Hub)
resource "aws_lambda_function" "libretranslate" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec_role.arn
  package_type  = "Image"

  # 🔄 Usando imagem do Docker Hub em vez do ECR
  image_uri = "docker.io/${var.docker_hub_user}/${var.docker_image_name}:latest"

  memory_size   = 1024  # Melhor custo-benefício
  timeout       = 20    # Timeout ajustado para segurança
  architectures = ["arm64"]  # Usa Graviton2 para menor custo

  environment {
    variables = {
      LT_UPDATE_MODELS = "false"
      AUTH_USERNAME    = var.auth_username
      AUTH_KEY         = var.auth_key
    }
  }
}

# 🌍 Criar o API Gateway para expor a Lambda como um serviço HTTP
resource "aws_apigatewayv2_api" "libretranslate_api" {
  name          = "LibreTranslateAPI"
  protocol_type = "HTTP"
}

# 🔗 Criar a Integração da API Gateway com a AWS Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.libretranslate_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.libretranslate.invoke_arn
}

# 📢 Criar a Rota para receber requisições na API Gateway
resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.libretranslate_api.id
  route_key = "GET /translate"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# 🚀 Criar a Stage do API Gateway
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.libretranslate_api.id
  name        = "default"
  auto_deploy = true
}

# 🔓 Permitir que o API Gateway invoque a AWS Lambda
resource "aws_lambda_permission" "apigateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.libretranslate.function_name
  principal     = "apigateway.amazonaws.com"
}

# 📤 Outputs Importantes
output "lambda_function_name" {
  value = aws_lambda_function.libretranslate.function_name
}

output "api_gateway_url" {
  value = aws_apigatewayv2_stage.default_stage.invoke_url
}
