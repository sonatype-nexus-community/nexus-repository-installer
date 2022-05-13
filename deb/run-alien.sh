#!/bin/bash
set -e

export RPM_BASENAME=$1
echo "RPM_BASENAME: ${RPM_BASENAME}"

export RPM_NAME=$2
echo "RPM_NAME: ${RPM_NAME}"

# split up running of alien program to allow us to inject rpm requires into deb depends stanza of debian control file
alien --generate --to-deb --scripts "/data/build/${RPM_NAME}"
#cat "${RPM_BASENAME}/debian/control"
sed -i -e 's/Depends: \${shlibs:Depends}/Depends: \${shlibs:Depends}, openjdk-8-jdk-headless | java8-sdk-headless/' "${RPM_BASENAME}/debian/control"
#cat "${RPM_BASENAME}/debian/control"

cd "${RPM_BASENAME}"
dpkg-buildpackage
