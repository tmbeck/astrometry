#! /bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get -y update && apt-get install -y apt-utils && \
    apt install -y --no-install-recommends tzdata && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get install -y --no-install-recommends \
    build-essential \
    make \
    gcc \
    git \
    file \
    pkg-config \
    wget \
    curl \
    swig \
    netpbm \
    wcslib-dev \
    wcslib-tools \
    zlib1g-dev \
    libbz2-dev \
    libcairo2-dev \
    libcfitsio-dev \
    libcfitsio-bin \
    libgsl-dev \
    libjpeg-dev \
    libnetpbm10-dev \
    libpng-dev \
    python3 \
    python3-dev \
    python3-pip \
    python3-pil \
    python3-tk \
    python3-setuptools \
    python3-wheel \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
