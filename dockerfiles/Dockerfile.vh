#
# LinuxGSM Valheim Dockerfile
#
# https://github.com/GameServerManagers/docker-gameserver
#

FROM gameservermanagers/linuxgsm:ubuntu-22.04
LABEL maintainer="LinuxGSM <me@danielgibbs.co.uk>"
ARG SHORTNAME='vh'
ENV GAMESERVER='vhserver'

WORKDIR /app

COPY data/ubuntu-22.04.csv ubuntu-22.04.csv

## Auto install game server requirements
RUN echo "**** Install  libc6-dev ****" \
  && apt-get update \
  && apt-get install -y  libc6-dev \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

HEALTHCHECK --interval=1m --timeout=1m --start-period=2m --retries=1 CMD /app/entrypoint-healthcheck.sh || exit 1

RUN date > /build-time.txt
# port
EXPOSE 2456

ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]
