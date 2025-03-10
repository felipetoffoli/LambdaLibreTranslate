# Usar a imagem oficial do LibreTranslate
FROM libretranslate/libretranslate:v1.6.2

# Definir o diretório de trabalho
WORKDIR /app

# Copiar os arquivos necessários para o container
COPY app.py /app/
COPY entrypoint.sh /app/

# 🔹 Alterar permissões antes de trocar de usuário
USER root
RUN chmod +x /app/entrypoint.sh

# 🔹 Voltar para o usuário original para segurança
USER libretranslate

# Expor a porta 5000 para a API do LibreTranslate
EXPOSE 5000

# Definir variáveis para evitar downloads automáticos
ENV LT_UPDATE_MODELS=false

# Executar script de entrada que inicia a API
ENTRYPOINT ["/app/entrypoint.sh"]
