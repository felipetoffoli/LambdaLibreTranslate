
# 🏆 LambdaLibreTranslate
![AWS Lambda](https://img.shields.io/badge/AWS-Lambda-orange)
![Terraform](https://img.shields.io/badge/IaC-Terraform-blue)
![Docker Hub](https://img.shields.io/badge/Docker-Hub-lightblue)

LambdaLibreTranslate é uma implementação do **[LibreTranslate](https://github.com/LibreTranslate/LibreTranslate)** para rodar de forma otimizada na **AWS Lambda**, utilizando **Docker**, **Terraform** para infraestrutura como código e **autenticação Basic Auth** para segurança.

## 🚀 Tecnologias Utilizadas
- **[LibreTranslate](https://github.com/LibreTranslate/LibreTranslate)** – API de tradução de código aberto.
- **AWS Lambda** – Execução **serverless** otimizada para baixo custo.
- **[Docker Hub - autovaloria1/libretranslate-lambda](https://hub.docker.com/repository/docker/autovaloria1/libretranslate-lambda/)** – Armazena a imagem para facilitar o deploy.
- **API Gateway** – Exposição HTTP para comunicação com a Lambda.
- **Terraform** – Automação da infraestrutura AWS.
- **Basic Auth** – Segurança no acesso à API.

---

## 🛠️ **Instalação e Deploy**
O deploy da aplicação é feito **totalmente automatizado** via Terraform e Docker.

### **1️⃣ Configurar AWS CLI com SSO**
Antes de tudo, certifique-se de estar **logado na AWS** via **AWS SSO**:
```sh
aws sso login --profile default
```

### **2️⃣ Implantar com Terraform**
O Terraform cria **a AWS Lambda, API Gateway e permissões** automaticamente.

```sh
terraform init
terraform apply -auto-approve
```

Após a execução, será exibida a **URL da API** gerada pelo API Gateway.

---

## 🐳 **Usando a Imagem Docker do Docker Hub**
A imagem do **LambdaLibreTranslate** já está disponível no **Docker Hub**:

🔗 **[Docker Hub - autovaloria1/libretranslate-lambda](https://hub.docker.com/repository/docker/autovaloria1/libretranslate-lambda/)**

Se quiser rodar localmente:
```sh
docker run -p 5000:5000 autovaloria1/libretranslate-lambda
```
Agora, acesse **http://localhost:5000** para testar a API.

---

### **3️⃣ Executar o Deploy Automático (`deploy.cmd`)**
Para facilitar, há um **script `deploy.cmd`** que executa **todos os passos acima automaticamente**. Basta rodar:

```sh
deploy.cmd
```

O script irá:
✅ Autenticar no AWS SSO  
✅ Executar o Terraform  
✅ Atualizar a AWS Lambda com a nova imagem do Docker Hub  
✅ Exibir a URL final da API  

---

## 📡 **Uso da API**
A API segue o padrão do **LibreTranslate**, mas exige **autenticação Basic Auth**.

### **🔹 Exemplo de Requisição (Sem Auth)**
```sh
curl -X GET "https://<API_GATEWAY_URL>/translate?text=hello&source_lang=en&target_lang=pt"
```
**Resposta esperada**:
```json
{
    "error": "Unauthorized"
}
```

---

### **🔹 Exemplo de Requisição (Com Basic Auth)**
```sh
curl -X GET "https://<API_GATEWAY_URL>/translate?text=hello&source_lang=en&target_lang=pt" \
     -H "Authorization: Basic $(echo -n 'meuusuario:minhasenha' | base64)"
```
**Resposta esperada**:
```json
{
    "translated_text": "olá"
}
```

---

## 🔒 **Segurança**
- **Autenticação Basic Auth** para evitar acesso público não autorizado.
- **Usuário e senha armazenados em variáveis de ambiente na AWS Lambda**.
- **API protegida por AWS API Gateway**, podendo ser configurada com **WAF** se necessário.

---

## 📜 **Licença**
Este projeto utiliza o **LibreTranslate**, que é open-source, e segue a licença **AGPL**.  
Leia mais sobre a licença original do **[LibreTranslate aqui](https://github.com/LibreTranslate/LibreTranslate/blob/main/LICENSE)**.

---

## 👨‍💻 **Contribuição**
Sinta-se livre para contribuir com melhorias!  
Abra um **Pull Request** ou entre em contato.  

