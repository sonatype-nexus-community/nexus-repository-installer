FROM       jswank/centos-rpm:7
MAINTAINER Jason Swank <jswank@sonatype.com>

COPY . /data

RUN chown -R nobody /data/*

VOLUME /data

USER nobody
WORKDIR /data
