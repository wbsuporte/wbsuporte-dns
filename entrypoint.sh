#!/bin/bash
set -e

echo "================================="
echo " WBSuporte DNS"
echo " Starting Unbound"
echo "================================="

mkdir -p /var/lib/unbound
chown -R unbound:unbound /var/lib/unbound

# Cria/atualiza a trust anchor do DNSSEC se necessário
if [ ! -f /var/lib/unbound/root.key ]; then
    echo ">> Criando root.key..."
    unbound-anchor -a /var/lib/unbound/root.key
    chown unbound:unbound /var/lib/unbound/root.key
fi

echo ">> Validando configuração..."
unbound-checkconf /etc/unbound/unbound.conf

echo ">> Iniciando Unbound..."
exec /usr/sbin/unbound -d -c /etc/unbound/unbound.conf
