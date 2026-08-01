#!/bin/bash
set -e

echo "================================="
echo " WBSuporte DNS"
echo " Starting Unbound"
echo "================================="

unbound-checkconf /etc/unbound/unbound.conf

exec /usr/sbin/unbound -d -c /etc/unbound/unbound.conf
