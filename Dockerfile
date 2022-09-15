FROM ubuntu:22.04 AS base

# ----------------------------------------------
#               BASE INSTALLATION
# ----------------------------------------------
COPY ./base /install/base
WORKDIR /install/base
RUN ["./install_dependencies.sh"]

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1
RUN pip install --no-cache-dir -r /install/base/requirements.txt

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
