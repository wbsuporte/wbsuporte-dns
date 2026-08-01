FROM debian:13-slim

LABEL org.opencontainers.image.title="WBSuporte DNS"
LABEL org.opencontainers.image.description="Recursive DNS Resolver based on Unbound"
LABEL org.opencontainers.image.version="0.1.0"
LABEL org.opencontainers.image.vendor="WBSuporte"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    unbound \
    unbound-anchor \
    ca-certificates \
    curl \
    bash \
    procps \
    iproute2 \
    dnsutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY conf/ /etc/unbound/
COPY data/ /var/lib/unbound/

RUN mkdir -p /var/lib/unbound && \
    chown -R unbound:unbound /var/lib/unbound && \
    unbound-checkconf /etc/unbound/unbound.conf

EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 8953/tcp

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
