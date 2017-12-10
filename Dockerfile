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
  git \
  libssl-dev \
  ssl-cert \
  devscripts \
  quilt \
  debhelper \
  fakeroot \
  equivs

WORKDIR /tmp/src/freeradius-server
RUN git clone https://github.com/FreeRADIUS/freeradius-server.git .
RUN git checkout release_3_0_15
RUN fakeroot debian/rules clean
RUN yes | mk-build-deps -ir debian/control
RUN dpkg-buildpackage -rfakeroot -b -uc

RUN cd .. && dpkg -i libfreeradius3_3.0.15+git_amd64.deb freeradius-common_3.0.15+git_all.deb && \
  dpkg -i freeradius-config_3.0.15+git_amd64.deb freeradius_3.0.15+git_amd64.deb && \
  dpkg -i freeradius-utils_3.0.15+git_amd64.deb freeradius-rest_3.0.15+git_amd64.deb

# all available packages
# freeradius-common_3.0.15+git_all.deb        freeradius-redis_3.0.15+git_amd64.deb
# freeradius-config_3.0.15+git_amd64.deb      freeradius-rest_3.0.15+git_amd64.deb
# freeradius-dbg_3.0.15+git_amd64.deb         freeradius-server/
# freeradius-dhcp_3.0.15+git_amd64.deb        freeradius-utils_3.0.15+git_amd64.deb
# freeradius-iodbc_3.0.15+git_amd64.deb       freeradius-yubikey_3.0.15+git_amd64.deb
# freeradius-krb5_3.0.15+git_amd64.deb        freeradius_3.0.15+git_amd64.changes
# freeradius-ldap_3.0.15+git_amd64.deb        freeradius_3.0.15+git_amd64.deb
# freeradius-memcached_3.0.15+git_amd64.deb   libfreeradius-dev_3.0.15+git_amd64.deb
# freeradius-mysql_3.0.15+git_amd64.deb       libfreeradius3_3.0.15+git_amd64.deb
# freeradius-postgresql_3.0.15+git_amd64.deb

WORKDIR /

# clean packages
RUN apt-get purge -y git devscripts quilt debhelper fakeroot equivs && \
  apt-get autoremove -y && apt-get clean -y && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/src

# put right config
RUN service freeradius stop
COPY config/*  /etc/freeradius/
COPY sites-enabled/*  /etc/freeradius/sites-enabled/
COPY mods-enabled/*  /etc/freeradius/mods-enabled/

EXPOSE \
  1812/udp \
  1813/udp \
  18120

# CMD ["freeradius", "-X"]
CMD ["tail", "-f", "/dev/null"]
