#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "[1/4] Validando compose..."
docker compose -f docker-compose.isp.yml config >/dev/null

echo "[2/4] Criando diretórios de dados..."
mkdir -p data/01 data/02 data/03 monitoring

echo "[3/4] Subindo ambiente ISP..."
docker compose -f docker-compose.isp.yml up -d

echo "[4/4] Verificando status..."
docker compose -f docker-compose.isp.yml ps

echo "Ambiente ISP iniciado com sucesso."
