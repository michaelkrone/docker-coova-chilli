FROM ubuntu:16.04
LABEL \
  org.label-schema.name="michaelkrone/freeradius" \
  org.label-schema.description="Michael Krone <michael.krone@outlook.com>" \
  org.label-schema.url="https://github.com/michaelkrone/docker-freeradius" \
  org.label-schema.vcs-url="https://github.com/michaelkrone/docker-freeradius.git" \
  org.label-schema.docker.dockerfile="./Dockerfile" \
  org.label-schema.vcs-type="Git" \
  org.label-schema.license="GPLv2" \
  org.label-schema.build-date=${BUILD_DATE} \
  org.label-schema.vcs-ref=${VCS_REF} \
  org.label-schema.version=${VERSION}

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
  freeradius \
  freeradius-utils

RUN service freeradius stop

# clean packages
RUN apt-get autoremove -y && apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# put right config
COPY config/clients.conf /etc/freeradius/

EXPOSE \
  1812/udp \
  1813/udp \
  18120

WORKDIR /

CMD ["freeradius", "-X"]