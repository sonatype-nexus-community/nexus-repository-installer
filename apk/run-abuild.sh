#!/bin/sh

export APK_VERSION=$1
echo "APK_VERSION: ${APK_VERSION}"

#cat /home/packager/nexus-repository-manager/APKBUILD
sed -i -e "s/pkgver=\"APK_VERSION\"/pkgver=\"${APK_VERSION}\"/" "/home/packager/nexus-repository-manager/APKBUILD"
#cat /home/packager/nexus-repository-manager/APKBUILD

# todo fix private key handling
#abuild-keygen -a -i
abuild-keygen -a -n

cd /home/packager/nexus-repository-manager/
abuild checksum

#abuild -r
abuild -r -k -K -v
