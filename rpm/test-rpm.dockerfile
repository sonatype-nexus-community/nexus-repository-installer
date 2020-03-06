FROM       centos:7

COPY ./ /data

#RUN yum -y install wget

VOLUME /data
WORKDIR /data

# get systemd happy in default centos image - no joy
