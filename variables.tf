variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "aws_sso_profile" {
  description = "Nome do perfil AWS SSO configurado no AWS CLI"
  type        = string
  default     = "default"
}

variable "lambda_function_name" {
  description = "Nome da função AWS Lambda"
  type        = string
  default     = "LibreTranslateLambda"
}

variable "docker_hub_user" {
  description = "Nome do usuário no Docker Hub"
  type        = string
  default     = "meu-usuario"
}

variable "docker_image_name" {
  description = "Nome da imagem no Docker Hub"
  type        = string
  default     = "libretranslate-lambda"
}

variable "auth_username" {
  description = "Usuário para autenticação Basic Auth"
  type        = string
  default     = "meuusuario"
}

variable "auth_key" {
  description = "Senha/API Key para autenticação Basic Auth"
  type        = string
  default     = "minhasenha"
}
