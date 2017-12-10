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
  freeradius-utils \
  git \
  # build-essential \
  # libssl-dev \
  # libcurl4-openssl-dev \
  # libjson-c-dev \
  devscripts \
  quilt \
  debhelper \
  fakeroot \
  equivs

WORKDIR /tmp/freeradius-server

RUN git clone https://github.com/FreeRADIUS/freeradius-server.git .
RUN git checkout release_3_0_15
RUN fakeroot debian/rules clean
RUN mk-build-deps -ir debian/control
RUN dpkg-buildpackage -rfakeroot -b -uc

WORKDIR /tmp
RUN dpkg -i

WORKDIR /

# clean packages
RUN apt-get purge -y git build-essential && \
  apt-get autoremove -y && apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/freeradius-server

# RUN service freeradius stop
# put right config
COPY config/*  /usr/local/etc/freeradius/
COPY sites-enabled/*  /usr/local/etc/freeradius/sites-enabled/
COPY mods-enabled/*  /usr/local/etc/freeradius/mods-enabled/

EXPOSE \
  1812/udp \
  1813/udp \
  18120

WORKDIR /

# CMD ["freeradius", "-X"]
CMD ["tail", "-f", "/dev/null"]
