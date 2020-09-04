

FROM alpine:latest

RUN     apk -U add alpine-sdk

RUN     mkdir -p /var/cache/distfiles && \
        adduser -D packager && \
        addgroup packager abuild && \
        chgrp abuild /var/cache/distfiles && \
        chmod g+w /var/cache/distfiles && \
        echo "packager    ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
        git config --global user.name "Sonatype Community" && \
        git config --global user.email "community-group@sonatype.com" && \
        git clone git://git.alpinelinux.org/aports && \
        sed -i -e 's/#PACKAGER="Your Name <your@email.address>"/PACKAGER="Sonatype Community <community-group@sonatype.com>"/' "/etc/abuild.conf" && \
        mkdir -p /var/cache/distfiles && \
        chmod a+w /var/cache/distfiles

#ADD     apk/setup.sh /home/packager/bin/setup.sh
ADD     apk/APKBUILD /home/packager/nexus-repository-manager/APKBUILD
ADD     apk/nexus-repository-manager.* /home/packager/nexus-repository-manager/

RUN     chmod -R a+w /home/packager/nexus-repository-manager

#WORKDIR /work

COPY . /data
RUN chown -R nobody /data/*
VOLUME /data

#USER nobody
WORKDIR /data

USER    packager

