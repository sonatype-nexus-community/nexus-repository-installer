FROM       jswank/centos-rpm:7
MAINTAINER Jason Swank <jswank@sonatype.com>

RUN yum -y install expect

COPY ./ /data
RUN chown -R nobody /data/*
VOLUME /data

USER nobody
WORKDIR /data
