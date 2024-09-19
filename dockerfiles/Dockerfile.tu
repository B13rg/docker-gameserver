#
# LinuxGSM Tower Unite Dockerfile
#
# https://github.com/GameServerManagers/docker-gameserver
#

FROM gameservermanagers/linuxgsm:ubuntu-22.04
LABEL maintainer="LinuxGSM <me@danielgibbs.co.uk>"
ARG SHORTNAME='tu'
ENV GAMESERVER='tuserver'

WORKDIR /app

COPY data/ubuntu-22.04.csv ubuntu-22.04.csv

## Auto install game server requirements
RUN depshortname=$(cat ubuntu-22.04.csv |awk -v shortname="tu" -F, '$1==shortname {$1=""; print $0}') \
  && if [ -n "${depshortname}" ]; then \
  echo "**** Install ${depshortname} ****" \
  && apt-get update \
  && apt-get install -y ${depshortname} \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
  fi

HEALTHCHECK --interval=1m --timeout=1m --start-period=2m --retries=1 CMD /app/entrypoint-healthcheck.sh || exit 1

RUN date > /build-time.txt

ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]
