#
# LinuxGSM Stationeers Dockerfile
#
# https://github.com/GameServerManagers/docker-gameserver
#

FROM gameservermanagers/linuxgsm:ubuntu-22.04
LABEL maintainer="LinuxGSM <me@danielgibbs.co.uk>"
ARG SHORTNAME='st'
ENV GAMESERVER='stserver'

WORKDIR /app

COPY data/ubuntu-22.04.csv ubuntu-22.04.csv

## Auto install game server requirements
RUN echo "**** Install  libxml2-utils ****" \
  && apt-get update \
  && apt-get install -y  libxml2-utils \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

HEALTHCHECK --interval=1m --timeout=1m --start-period=2m --retries=1 CMD /app/entrypoint-healthcheck.sh || exit 1

RUN date > /build-time.txt

ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]
