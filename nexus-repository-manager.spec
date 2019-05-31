Name:		nexus-repository-manager
Version:	%%VERSION%%
Release:	%%RELEASE%%
Summary:	Nexus Repository Manager 3
License:	Proprietary
URL:		https://www.sonatype.com
Source0:	%%BUNDLE_FILE%%
Source1:        %{name}-%{version}-rpm.tar.gz
BuildRoot:	%{_tmppath}/nexus-repository-manager
BuildArch:	noarch

#Prefix: /

%define __jar_repack %{nil}

%description
Nexus Repository Manager 3

%prep
rm -rf ${RPM_PACKAGE_NAME}-${RPM_PACKAGE_VERSION}
mkdir -p ${RPM_PACKAGE_NAME}-${RPM_PACKAGE_VERSION}
cd ${RPM_PACKAGE_NAME}-${RPM_PACKAGE_VERSION}
tar -xz \
  -f %{SOURCE0}

#tar -xz -f %{SOURCE1}

%build
cd ${RPM_PACKAGE_NAME}-${RPM_PACKAGE_VERSION}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/opt/sonatype/nexus3
mkdir -p %{buildroot}/opt/sonatype/sonatype-work/nexus3
rsync -a ${RPM_PACKAGE_NAME}-${RPM_PACKAGE_VERSION}/nexus-$(echo ${RPM_PACKAGE_VERSION} | tr '_' '-')/ %{buildroot}/opt/sonatype/nexus3
rsync -a ${RPM_PACKAGE_NAME}-${RPM_PACKAGE_VERSION}/sonatype-work/nexus3/ %{buildroot}/opt/sonatype/sonatype-work/nexus3

#patch config
perl -p -i -e 's/#run_as_user=""/run_as_user="nexus3"/' %{buildroot}/opt/sonatype/nexus3/bin/nexus.rc
perl -p -i -e 's/\.\.\/sonatype-work/\/opt\/sonatype\/sonatype-work/g' %{buildroot}/opt/sonatype/nexus3/bin/nexus.vmoptions

mkdir -p %{buildroot}/etc/init.d
ln -sf /opt/sonatype/nexus3/bin/nexus %{buildroot}/etc/init.d/nexus3

%clean
rm -rf %{buildroot}

%pre
echo pre $1
if [ $1 = 1 ] || [ "$1" = "install" ]; then
[ -d /opt/sonatype/sonatype-work/nexus3 ] || mkdir -p /opt/sonatype/sonatype-work/nexus3
# create user account
getent group nexus3 >/dev/null || groupadd -r nexus3
getent passwd nexus3 >/dev/null || \
	useradd -r -g nexus3 -d /opt/sonatype/sonatype-work/nexus3 -m -c "nexus3 role account" -s /bin/bash nexus3
fi
# stop the service before upgrading
if [ $1 = 2 ]; then
  /sbin/service nexus3 stop
elif [ "$1" = "upgrade" ]; then
  /usr/sbin/service nexus3 stop
fi

%post
echo post $1
# start the service upon first installation
if [ $1 = 1 ]; then
  /sbin/chkconfig --add nexus3
  /sbin/service nexus3 start
elif [ "$1" = "configure" ]; then
  update-rc.d nexus3 defaults
  /usr/sbin/service nexus3 start
fi
# start the service after upgrading
if [ $1 = 2 ]; then
  /sbin/service nexus3 start
elif [ "$1" = "upgrade" ]; then
  /usr/sbin/service nexus3 start
fi

%preun
echo preun $1
if [ $1 = 0 ]; then
  /sbin/service nexus3 stop
  /sbin/chkconfig --del nexus3
elif [ "$1" = "remove" ]; then
  /usr/sbin/service nexus3 stop
  update-rc.d nexus3 remove
fi

%files
%defattr(-,root,root,-)
/etc/init.d/nexus3
/opt/sonatype/nexus3
%dir %config(noreplace) /opt/sonatype/nexus3/etc
%config(noreplace) /opt/sonatype/nexus3/bin/nexus.rc
%config(noreplace) /opt/sonatype/nexus3/bin/nexus.vmoptions
%defattr(-,nexus3,nexus3)
/opt/sonatype/sonatype-work/nexus3

%changelog
* Wed May 29 2019 Dan Rollo <drollo@sonatype.com>
automatically start and stop service daemon as needed during initial install and upgrades
* Tue May 21 2019 Dan Rollo <drollo@sonatype.com>
initial .spec from prior work of Jason Swank, Rick Briganti, Alvin Gunkel
