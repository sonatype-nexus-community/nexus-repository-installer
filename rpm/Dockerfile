FROM       jswank/centos-rpm:7
MAINTAINER Jason Swank <jswank@sonatype.com>

COPY ./ /data

RUN yum -y install expect
RUN chown -R nobody /data/*

VOLUME /data

USER nobody
WORKDIR /data