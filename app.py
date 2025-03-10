import json
import os
import base64
import requests

# 🔹 Definição das credenciais via variáveis de ambiente
VALID_USERNAME = os.getenv("AUTH_USERNAME", "defaultuser")  # Nome de usuário padrão
VALID_API_KEY = os.getenv("AUTH_KEY", "defaultpassword")  # Senha padrão

# 🔹 URL da API do LibreTranslate rodando no container
LT_URL = "http://localhost:5000"

def authenticate(event):
    """ Função para verificar Basic Auth """
    auth_header = event.get("headers", {}).get("Authorization", "")

    if not auth_header.startswith("Basic "):
        return False

    # Decodifica credenciais
    encoded_credentials = auth_header.split("Basic ")[1]
    decoded_credentials = base64.b64decode(encoded_credentials).decode("utf-8")
    username, password = decoded_credentials.split(":")

    return username == VALID_USERNAME and password == VALID_API_KEY

def lambda_handler(event, context):
    """ Handler da AWS Lambda """
    
    # 🔹 Verificar autenticação
    if not authenticate(event):
        return {
            "statusCode": 401,
            "body": json.dumps({"error": "Unauthorized"})
        }

    # 🔹 Obtendo parâmetros da Query String
    query_params = event.get("queryStringParameters", {})

    text = query_params.get("text", "")
    source_lang = query_params.get("source_lang", "en")
    target_lang = query_params.get("target_lang", "pt")

    if not text:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Texto não informado"})
        }

    # 🔹 Fazendo requisição para a API interna do LibreTranslate
    response = requests.post(
        f"{LT_URL}/translate",
        json={"q": text, "source": source_lang, "target": target_lang, "format": "text"}
    )

    if response.status_code != 200:
        return {
            "statusCode": response.status_code,
            "body": json.dumps({"error": "Erro ao traduzir"})
        }

    translated_text = response.json().get("translatedText", "")

    return {
        "statusCode": 200,
        "body": json.dumps({"translated_text": translated_text})
    }
