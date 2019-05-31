# todo: Figure out how to get 'alien' working on smaller (alpine) distro - needs 'debhelper' equivalent
#FROM alpine:latest
#RUN apk add --no-cache rpm rpm-common rpm2cpio dpkg-dev alien
#RUN apk add --no-cache rpm dpkg-dev perl g++ make fakeroot alien
#RUN apk add --no-cache autoconf automake binutils ca-certificates cpio curl dbus dpkg-dev fakeroot file g++ gcc gettext gnupg libssl1.1 libtool libxml2 m4 make openssl patch perl rpm shared-mime-info alien
#RUN apk add --no-cache autoconf automake autopoint autotools-dev binutils binutils-common binutils-x86-64-linux-gnu bsdmainutils build-essential ca-certificates cpio cpp cpp-7 curl dbus debhelper debugedit dh-autoreconf dh-strip-nondeterminism dirmngr dpkg-dev fakeroot file g++ g++-7 gcc gcc-7 gcc-7-base gettext gettext-base gnupg gnupg-l10n gnupg-utils gpg gpg-agent gpg-wks-client gpg-wks-server gpgconf gpgsm groff-base intltool-debian krb5-locales libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl libapparmor1 libarchive-cpio-perl libarchive-zip-perl libarchive13 libasan4 libasn1-8-heimdal libassuan0 libatomic1 libbinutils libbsd0 libc-dev-bin libc6-dev libcap2 libcc1-0 libcilkrts5 libcroco3 libcurl4 libdbus-1-3 libdpkg-perl libdw1 libelf1 libexpat1 libfakeroot libfile-fcntllock-perl libfile-stripnondeterminism-perl libgcc-7-dev libgdbm-compat4 libgdbm5 libglib2.0-0 libglib2.0-data libgomp1 libgssapi-krb5-2 libgssapi3-heimdal libhcrypto4-heimdal libheimbase1-heimdal libheimntlm0-heimdal libhx509-5-heimdal libicu60 libisl19 libitm1 libk5crypto3 libkeyutils1 libkrb5-26-heimdal libkrb5-3 libkrb5support0 libksba8 libldap-2.4-2 libldap-common liblocale-gettext-perl liblsan0 libltdl-dev libltdl7 liblua5.2-0 liblzo2-2 libmagic-mgc libmagic1 libmail-sendmail-perl libmpc3 libmpfr6 libmpx2 libnghttp2-14 libnpth0 libnspr4 libnss3 libperl5.26 libpipeline1 libpopt0 libpsl5 libquadmath0 libreadline7 libroken18-heimdal librpm8 librpmbuild8 librpmio8 librpmsign8 librtmp1 libsasl2-2 libsasl2-modules libsasl2-modules-db libsigsegv2 libsqlite3-0 libssl1.1 libstdc++-7-dev libsys-hostname-long-perl libtimedate-perl libtool libtsan0 libubsan0 libwind0-heimdal libxml2 linux-libc-dev m4 make man-db manpages manpages-dev multiarch-support netbase openssl patch perl perl-modules-5.26 pinentry-curses po-debconf publicsuffix readline-common rpm rpm-common rpm2cpio shared-mime-info xdg-user-dirs xz-utils alien

#FROM debian:stable-slim
FROM debian:stable
#FROM ubuntu:latest
RUN apt-get update && apt-get install -y alien

COPY . /data

RUN chown -R nobody /data/*

VOLUME /data

#USER nobody
WORKDIR /data
#WORKDIR /tmp

