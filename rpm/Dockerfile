FROM       jswank/centos-rpm:7
MAINTAINER Jason Swank <jswank@sonatype.com>

RUN yum -y install expect

# force sha256 signature of rpm, instead of old default of sha1 used by CentOS7
RUN echo '%_gpg_digest_algo sha256' >> /usr/lib/rpm/macros

COPY ./ /data
RUN chown -R nobody /data/*
VOLUME /data

USER nobody
WORKDIR /data
