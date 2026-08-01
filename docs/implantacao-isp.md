# Implantação em produção ISP

## Objetivo

Este guia estabelece a implantação operacional da arquitetura DNS para provedores de internet com milhares de clientes, usando o stack atual de Unbound em múltiplos nós, monitoramento com Prometheus e Grafana, e regras de segurança para produção.

## 1) Pré-requisitos

Antes da implantação, confirme:

- Docker instalado no host
- Docker Compose instalado
- porta 53/UDP e 53/TCP liberadas para a rede de clientes
- rede administrativa separada da rede de clientes
- firewall e ACLs preparados
- acesso ao host com permissão para manipular redes e serviços
- armazenamento local para cachê e logs

## 2) Estrutura recomendada

### Rede lógica

- Rede cliente: recebe consultas DNS dos assinantes
- Rede administrativa: acessa o painel de controle e o monitoramento
- Rede upstream: saída para internet e servidores raiz

### Topologia

- 3 nós de resolver em um mesmo datacenter ou em 3 hosts distintos
- VIP ou load balancer de entrada para distribuir tráfego
- monitoramento centralizado em Prometheus e Grafana
- exportadores de métricas por nó

## 3) Passo a passo de implantação

### 3.1. Clonar e preparar o repositório

```bash
git clone https://github.com/wbsuporte/wbsuporte-dns.git
cd wbsuporte-dns
```

### 3.2. Validar a configuração

```bash
docker compose -f docker-compose.isp.yml config
```

Se a sintaxe estiver correta, o Compose mostrará os serviços: `dns-01`, `dns-02`, `dns-03`, `prometheus` e `grafana`.

### 3.3. Criar diretórios para dados dos nós

```bash
mkdir -p data/01 data/02 data/03 monitoring
```

### 3.4. Subir os serviços

```bash
docker compose -f docker-compose.isp.yml up -d
```

### 3.5. Verificar saúde dos serviços

```bash
docker compose -f docker-compose.isp.yml ps
docker compose -f docker-compose.isp.yml logs -f
```

### 3.6. Validar o DNS em cada nó

Use o comando abaixo em cada host ou via rede interna:

```bash
dig @127.0.0.1 -p 5301 example.com
```

Também pode validar a resposta em qualquer um dos nós:

```bash
dig @127.0.0.1 -p 5302 example.com
dig @127.0.0.1 -p 5303 example.com
```

## 4) Monitoramento e alertas

### Prometheus

Acesse:

```text
http://<host>:9090
```

### Grafana

Acesse:

```text
http://<host>:3000
```

Credenciais padrão do exemplo:

- usuário: `admin`
- senha: `admin`

Configure dashboards com os targets de cada exportador do Unbound.

## 5) Firewall recomendado

A política mínima de produção deve incluir:

- permitir UDP/TCP 53 da rede cliente para o VIP ou resolver
- permitir UDP/TCP 53 para as redes internas autorizadas
- bloquear 8953 da rede pública
- bloquear acesso administrativo fora da rede gestão
- permitir saída para upstream e servidores raiz do DNS

Exemplo de regra conceitual:

```bash
# Permitido para clientes
iptables -A INPUT -p udp --dport 53 -s 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -s 10.0.0.0/8 -j ACCEPT

# Bloquear controle remoto da rede pública
iptables -A INPUT -p tcp --dport 8953 -j DROP
```

## 6) Estratégia de failover

Em produção, o objetivo é evitar indisponibilidade por falha de um nó.

### Procedimento ideal

- manter 2 ou 3 nós ativos
- usar VIP ou serviço de balanceamento para entrada do tráfego
- remover o nó problemático do giro do VIP sem afetar o restante
- validar logs e métricas do resolver antes de retornar ao cluster

### Rollback

Se uma configuração nova falhar:

```bash
git checkout <tag-anterior>

docker compose -f docker-compose.isp.yml down
docker compose -f docker-compose.isp.yml up -d
```

Confirmar rapidamente:

```bash
docker compose -f docker-compose.isp.yml ps
```

## 7) Boas práticas para operação

- manter os arquivos de configuração versionados em Git
- validar toda alteração com `docker compose config`
- testar novas configurações em um nó antes do rollout em lote
- manter logs de cada resolver em diretório dedicado
- monitorar cache hit rate, latência e SERVFAIL
- garantir política de manutenção sem interrupção

## 8) Checklist final de produção

- [ ] rede de clientes separada da administrativa
- [ ] portas 53 liberadas somente para redes autorizadas
- [ ] 8953 bloqueado fora da rede interna
- [ ] 3 nós de resolver operando
- [ ] Prometheus capturando os exporters
- [ ] Grafana com dashboard funcional
- [ ] ACLs revisadas para redes reais do ISP
- [ ] failover testado em ambiente controlado
- [ ] rollback validado

## 9) Conclusão

Esta implantação representa uma base sólida para ambiente ISP com milhares de clientes: alta disponibilidade, monitoramento centralizado, isolamento de rede e processo operacional controlado. Em larga escala, o próximo passo é integrar um load balancer ou VIP real e ajustar os parâmetros de cache e fila de consulta conforme volume de produção.
