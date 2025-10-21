FROM ubuntu:24.04

ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt update && apt install -y \
    wget \
    curl \
    cron \
    iptables \
    iptables-persistent \
    ca-certificates \
    && apt clean && apt autoremove -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Download and install EarnApp
RUN wget -qO- https://brightdata.com/static/earnapp/install.sh > /tmp/earnapp.sh && \
    archs=$(uname -m) && \
    PRODUCT="earnapp" && \
    VERSION=$(grep VERSION= /tmp/earnapp.sh | cut -d'"' -f2) && \
    if [ "$archs" = "x86_64" ] || [ "$archs" = "amd64" ]; then \
        file=$PRODUCT-x64-$VERSION; \
    elif [ "$archs" = "armv7l" ] || [ "$archs" = "armv6l" ]; then \
        file=$PRODUCT-arm7l-$VERSION; \
    elif [ "$archs" = "aarch64" ] || [ "$archs" = "arm64" ]; then \
        file=$PRODUCT-aarch64-$VERSION; \
    else \
        file=$PRODUCT-arm7l-$VERSION; \
    fi && \
    wget -cq --no-check-certificate https://cdn-earnapp.b-cdn.net/static/$file -O /usr/bin/earnapp && \
    chmod +x /usr/bin/earnapp && \
    rm /tmp/earnapp.sh

# Download and install GOST v3.2.5
RUN archs=$(uname -m) && \
    GOST_VERSION="3.2.5" && \
    if [ "$archs" = "x86_64" ] || [ "$archs" = "amd64" ]; then \
        GOST_ARCH="linux_amd64v3"; \
    elif [ "$archs" = "aarch64" ] || [ "$archs" = "arm64" ]; then \
        GOST_ARCH="linux_arm64v8"; \
    elif [ "$archs" = "armv7l" ]; then \
        GOST_ARCH="linux_armv7"; \
    else \
        GOST_ARCH="linux_amd64v3"; \
    fi && \
    wget -q https://github.com/go-gost/gost/releases/download/v${GOST_VERSION}/gost_${GOST_VERSION}_${GOST_ARCH}.tar.gz -O /tmp/gost.tar.gz && \
    mkdir -p /opt/gost && \
    tar -xzf /tmp/gost.tar.gz -C /opt/gost && \
    chmod +x /opt/gost/gost && \
    rm /tmp/gost.tar.gz

# Create gost user with UID 42069
RUN groupadd -g 42069 gost && \
    useradd -u 42069 -g 42069 -s /bin/bash -m gost

# Create necessary directories
RUN mkdir -p /etc/earnapp /scripts /var/log && \
    chmod a+wr /etc/earnapp

# Copy scripts
COPY scripts/entrypoint.sh /scripts/entrypoint.sh
COPY scripts/restart-earnapp.sh /scripts/restart-earnapp.sh
COPY scripts/restart-gost.sh /scripts/restart-gost.sh
COPY scripts/setup-iptables.sh /scripts/setup-iptables.sh

# Make scripts executable
RUN chmod +x /scripts/*.sh

VOLUME [ "/etc/earnapp" ]

ENTRYPOINT ["/scripts/entrypoint.sh"]
