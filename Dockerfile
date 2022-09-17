FROM ubuntu:22.04 AS base

# ----------------------------------------------
#               BASE INSTALLATION
# ----------------------------------------------
RUN apt-get -y update && apt-get install -y --no-install-recommends apt-utils
ARG DEBIAN_FRONTEND=noninteractive 
RUN apt-get install -y --no-install-recommends \
    apt-utils \
    tzdata \
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
    python3-tk \
    python3-setuptools \
    python3-wheel \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1
COPY ./base/requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt

FROM base as astrometry_base
# ----------------------------------------------
#            ASTROMETRY INSTALLATION
# ----------------------------------------------
COPY ./astrometry /install/astrometry
WORKDIR /
RUN ["/install/astrometry/compile_astrometry.sh"]
ENV PATH="/usr/local/astrometry/bin:${PATH}"
ENV PYTHONPATH="/astrometry.net"

FROM astrometry_base as nova
# ----------------------------------------------
#              NOVA INSTALLATION
# ----------------------------------------------
COPY ./nova /install/nova
COPY ./nova/django_db.py /astrometry.net/net/appsecrets/
COPY ./nova/my_fixtures.json /astrometry.net/net/fixtures/
WORKDIR /install/nova
RUN ["./install_nova.sh"]

# ----------------------------------------------
#                   CLEAN UP
# ----------------------------------------------
WORKDIR /
RUN ["rm","-rf","install/"]

# ----------------------------------------------
#                RUNTIME STUFF
# ----------------------------------------------
COPY ./nova/start_nova.sh /astrometry.net/net/
COPY ./nova/solve_script.sh /astrometry.net/net/
COPY ./docker-entrypoint.sh /
COPY ./client.py /
COPY ./astrometry/astrometry.cfg /usr/local/etc/astrometry.cfg
RUN apt purge -y build-essential make gcc git
RUN apt autoremove -y

FROM nova as astrometry
# ----------------------------------------------
#                  ENTRYPOINT
# ----------------------------------------------
WORKDIR /astrometry.net/net
ENTRYPOINT ["/docker-entrypoint.sh"]
# start nova by default
CMD ["nova"]
