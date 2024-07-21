FROM       jswank/centos-rpm:7
MAINTAINER Jason Swank <jswank@sonatype.com>

# workaround missing EOL CentOS mirrors. see: https://github.com/sonatype-nexus-community/nexus-repository-installer/issues/37
RUN sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
RUN sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo
RUN sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo

RUN yum -y install expect

# force sha256 signature of rpm, instead of old default of sha1 used by CentOS7
RUN echo '%_gpg_digest_algo sha256' >> /usr/lib/rpm/macros

COPY ./ /data
RUN chown -R nobody /data/*
VOLUME /data

USER nobody
WORKDIR /data
