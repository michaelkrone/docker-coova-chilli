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

# ENV CHILLI_PATH_PREFIX /usr/local

RUN apt-get update && apt-get install -y \
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
RUN git clone --depth 2 https://github.com/coova/coova-chilli.git /tmp/coova-chilli
WORKDIR /tmp/coova-chilli
RUN git fetch --all --tags --prune && git checkout tags/1.4

# create package
RUN ./bootstrap && ./configure --prefix=/usr/local \
  --enable-miniportal --with-openssl --enable-libjson \
  --enable-useragent --enable-sessionstate --enable-sessionid \
  --enable-chilliredir --enable-binstatusfile --enable-statusfile \
  --disable-static --enable-shared --enable-largelimits \
  --enable-proxyvsa --enable-chilliproxy --enable-chilliradsec --with-poll
RUN make
RUN make install

# maybe install package
# RUN debuild -us -uc -b
# RUN dpkg -i ../coova-chilli_*.deb

# clean packages
RUN apt-get purge -y git build-essential libtool autoconf automake gengetopt devscripts debhelper && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/src


# put right config
RUN cp /usr/local/etc/chilli/defaults /usr/local/etc/chilli/config
COPY chilli-config/default /usr/local/etc/chilli/default
COPY chilli-config/defaults.conf /usr/local/etc/chilli.conf
COPY chilli-config/main.conf /usr/local/etc/chilli/
COPY chilli-config/hs.conf /usr/local/etc/chilli/
COPY chilli-config/local.conf /usr/local/etc/chilli/
COPY scripts/ipup.sh /usr/local/etc/chilli/ipup.sh
RUN chmod 755 /usr/local/etc/chilli/ipup.sh

EXPOSE 3990 4990

# USER chilli

COPY chilli.conf /usr/local/etc/chilli/chilli.conf

# VOLUME /config

# RUN chmod 755 /usr/local/etc/chilli/ipup.sh
# RUN systemctl enable chilli
# RUN systemctl start chilli

# ENTRYPOINT ["/usr/local/sbin/chilli", "--debug", "--fg"]
ENTRYPOINT ["/usr/local/etc/init.d/chilli", "start"]
CMD ["--conf", "/usr/local/etc/chilli/chilli.conf"]
