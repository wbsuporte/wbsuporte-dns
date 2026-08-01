#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-127.0.0.1}"
PORT="${2:-53}"

echo "Verificando DNS em ${TARGET}:${PORT}"

if command -v drill >/dev/null 2>&1; then
  drill @"${TARGET}" -p "${PORT}" example.com >/dev/null
elif command -v dig >/dev/null 2>&1; then
  dig +short @"${TARGET}" -p "${PORT}" example.com >/dev/null
else
  echo "Nenhuma ferramenta de diagnóstico DNS encontrada (drill/dig)."
  exit 2
fi

echo "DNS ok: resposta recebida de ${TARGET}:${PORT}"
