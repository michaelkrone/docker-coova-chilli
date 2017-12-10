FROM ubuntu:16.04
LABEL \
  org.label-schema.name="michaelkrone/coova-chilli" \
  org.label-schema.description="Michael Krone <michael.krone@outlook.com>" \
  org.label-schema.url="https://github.com/michaelkrone/docker-coova-chilli" \
  org.label-schema.vcs-url="https://github.com/michaelkrone/docker-coova-chilli.git" \
  org.label-schema.docker.dockerfile="./Dockerfile" \
  org.label-schema.vcs-type="Git" \
  org.label-schema.license="GPLv2" \
  org.label-schema.build-date=${BUILD_DATE} \
  org.label-schema.vcs-ref=${VCS_REF} \
  org.label-schema.version=${VERSION}

RUN apt-get update -y && apt-get install -y \
  git \
  build-essential \
  libtool \
  autoconf \
  automake \
  gengetopt \
  devscripts \
  debhelper \
  libssl-dev \
  iptables \
  libjson-c-dev \
  haserl \
  net-tools

# grep git version of coova-chilli and install version 1.4
WORKDIR /tmp/coova-chilli
RUN git clone --depth 2 https://github.com/coova/coova-chilli.git .
RUN git fetch --all --tags --prune && git checkout tags/1.4

# create package
RUN ./bootstrap && ./configure --prefix= \
  --enable-miniportal --with-openssl --enable-libjson \
  --enable-useragent --enable-sessionstate --enable-sessionid \
  --enable-chilliredir --enable-binstatusfile --enable-statusfile \
  --disable-static --enable-shared --enable-largelimits \
  --enable-proxyvsa --enable-chilliproxy --enable-chilliradsec --with-poll
RUN make && make install

# clean packages
RUN apt-get purge -y \
  git \
  build-essential \
  libtool \
  autoconf \
  automake \
  gengetopt \
  devscripts \
  debhelper && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/coova-chilli

# put right config
COPY chilli-config/* /etc/chilli/
COPY scripts/* /etc/chilli/
RUN chmod 755 /etc/chilli/ipup.sh

EXPOSE 3990 4990

# RUN update-rc.d chilli defaults

WORKDIR /

# RUN useradd -s /sbin/nologin chilli
# RUN chown chilli /etc/chilli/*.conf
# USER chilli

# CMD ["/sbin/chilli", "--debug", "--fg", "--conf", "/etc/chilli/chilli.conf"]
CMD ["tail", "-f", "/dev/null"]