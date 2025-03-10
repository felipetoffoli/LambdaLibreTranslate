@echo off
setlocal enabledelayedexpansion

:: Configurações
set AWS_REGION=us-east-1
set AWS_SSO_PROFILE=default
set DOCKER_HUB_USER=meu-usuario
set DOCKER_IMAGE_NAME=libretranslate-lambda
set LAMBDA_NAME=LibreTranslateLambda

echo.
echo ===========================================
echo 🚀 INICIANDO O DEPLOY DO LIBRETRANSLATE 🚀
echo ===========================================
echo.

:: 1️⃣ Autenticar no AWS SSO
echo 🔹 Autenticando no AWS SSO...
aws sso login --profile %AWS_SSO_PROFILE%
if %ERRORLEVEL% neq 0 (
    echo ❌ Erro ao autenticar no AWS SSO.
    exit /b %ERRORLEVEL%
)

:: 2️⃣ Inicializar Terraform
echo 🔹 Inicializando Terraform...
terraform init
if %ERRORLEVEL% neq 0 (
    echo ❌ Erro ao inicializar Terraform.
    exit /b %ERRORLEVEL%
)

:: 3️⃣ Aplicar Terraform (criar infra)
echo 🔹 Criando infraestrutura na AWS...
terraform apply -auto-approve
if %ERRORLEVEL% neq 0 (
    echo ❌ Erro ao criar infraestrutura.
    exit /b %ERRORLEVEL%
)

:: 4️⃣ Login no Docker Hub
echo 🔹 Autenticando no Docker Hub...
docker login
if %ERRORLEVEL% neq 0 (
    echo ❌ Erro ao autenticar no Docker Hub.
    exit /b %ERRORLEVEL%
)

:: 5️⃣ Construir a Imagem Docker
echo 🔹 Construindo a imagem Docker...
docker build -t %DOCKER_HUB_USER%/%DOCKER_IMAGE_NAME% .
if %ERRORLEVEL% neq 0 (
    echo ❌ Erro ao construir a imagem Docker.
    exit /b %ERRORLEVEL%
)

:: 6️⃣ Enviar a imagem para o Docker Hub
echo 🔹 Enviando imagem para o Docker Hub...
docker tag %DOCKER_HUB_USER%/%DOCKER_IMAGE_NAME% %DOCKER_HUB_USER%/%DOCKER_IMAGE_NAME%:latest
docker push %DOCKER_HUB_USER%/%DOCKER_IMAGE_NAME%:latest
if %ERRORLEVEL% neq 0 (
    echo ❌ Erro ao enviar a imagem para o Docker Hub.
    exit /b %ERRORLEVEL%
)

:: 7️⃣ Atualizar a AWS Lambda para usar a nova imagem do Docker Hub
echo 🔹 Atualizando a Lambda com a nova imagem...
aws lambda update-function-code --function-name %LAMBDA_NAME% --image-uri docker.io/%DOCKER_HUB_USER%/%DOCKER_IMAGE_NAME%:latest
if %ERRORLEVEL% neq 0 (
    echo ❌ Erro ao atualizar a AWS Lambda.
    exit /b %ERRORLEVEL%
)

:: 8️⃣ Obter URL do API Gateway
for /f "tokens=*" %%i in ('terraform output -raw api_gateway_url') do set API_URL=%%i

:: 9️⃣ Exibir URL final
echo.
echo ===========================================
echo ✅ DEPLOY CONCLUÍDO COM SUCESSO! 🚀
echo 🔗 Acesse a API em: %API_URL%
echo ===========================================
echo.

endlocal
exit /b 0
