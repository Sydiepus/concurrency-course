FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ENV DEBIAN_FRONTEND=noninteractive

# Core tools + Java 21 + Python 3.12 tooling
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    unzip \
    zip \
    tar \
    htop \
    net-tools \
    iputils-ping \
    dnsutils \
    lsof \
    procps \
    netcat-openbsd \
    openssh-client \
    software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
    openjdk-21-jdk \
    python3.12 \
    python3.12-venv \
    python3-pip \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 2 \
    && rm -rf /var/lib/apt/lists/*

# Environment sanity
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${PATH}:/home/vscode/.local/bin"

RUN mkdir -p /workspace/labs /workspace/data /home/vscode/.local/bin \
    && chown -R vscode:vscode /workspace /home/vscode/.local

WORKDIR /workspace
