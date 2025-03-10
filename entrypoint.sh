#!/bin/sh

# Inicia o LibreTranslate em background (&)
./venv/bin/libretranslate --host 0.0.0.0 --port 5000 &

# Espera alguns segundos para garantir que o servidor está rodando
sleep 1

# Inicia a AWS Lambda Runtime Interface (permite execução na Lambda)
exec /var/runtime/bootstrap
