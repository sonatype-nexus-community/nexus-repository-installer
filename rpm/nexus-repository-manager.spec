Name:		nexus-repository-manager
Version:	%%VERSION%%
Release:	%%RELEASE%%
Summary:	Nexus Repository Manager 3
License:	Proprietary
Requires:       systemd
Requires:       java-17-openjdk-headless
URL:		https://www.sonatype.com
Source0:	%%BUNDLE_FILE%%
Source1:        %{name}-%{version}-rpm-extra.tar.gz
BuildRoot:	%{_tmppath}/nexus-repository-manager
BuildArch:	noarch

#Prefix: /

%define __jar_repack %{nil}
%define service_name  %{name}.service

%description
Nexus Repository Manager 3

%prep
rm -rf ${RPM_PACKAGE_NAME}-${RPM_PACKAGE_VERSION}
mkdir -p ${RPM_PACKAGE_NAME}-${RPM_PACKAGE_VERSION}
cd ${RPM_PACKAGE_NAME}-${RPM_PACKAGE_VERSION}
tar -xz \
  -f %{SOURCE0}

tar -xz -f %{SOURCE1}

%build
cd ${RPM_PACKAGE_NAME}-${RPM_PACKAGE_VERSION}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/opt/sonatype/nexus3
mkdir -p %{buildroot}/opt/sonatype/sonatype-work/nexus3
rsync -a --exclude 'jdk' ${RPM_PACKAGE_NAME}-${RPM_PACKAGE_VERSION}/nexus-$(echo ${RPM_PACKAGE_VERSION} | tr '_' '-')/ %{buildroot}/opt/sonatype/nexus3
rsync -a ${RPM_PACKAGE_NAME}-${RPM_PACKAGE_VERSION}/extra %{buildroot}/opt/sonatype/nexus3/
rsync -a ${RPM_PACKAGE_NAME}-${RPM_PACKAGE_VERSION}/sonatype-work/nexus3/ %{buildroot}/opt/sonatype/sonatype-work/nexus3

#patch config
perl -p -i -e 's/#run_as_user=""/run_as_user="nexus3"/' %{buildroot}/opt/sonatype/nexus3/bin/nexus
perl -p -i -e 's/\.\.\/sonatype-work/\/opt\/sonatype\/sonatype-work/g' %{buildroot}/opt/sonatype/nexus3/bin/nexus.vmoptions
perl -p -i -e 's/^EMBEDDED_JDK/#EMBEDDED_JDK/' %{buildroot}/opt/sonatype/nexus3/bin/nexus 

mkdir -p %{buildroot}/etc/systemd/system
ln -sf /opt/sonatype/nexus3/extra/daemon/%{service_name} %{buildroot}/etc/systemd/system/%{service_name}

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
if [ $1 = 2 ] || [ "$1" = "upgrade" ]; then
  if [ ! -f /etc/systemd/system/%{service_name} ]; then
    # use old init script to stop old service
    if [ $1 = 2 ]; then
      /sbin/service nexus3 stop
    elif [ "$1" = "upgrade" ]; then
      /usr/sbin/service nexus3 stop
    fi
  else
    systemctl stop %{service_name}
  fi
fi

%post
echo post $1
# start the service upon first installation
if [ $1 = 1 ] || [ "$1" = "configure" ]; then
  systemctl daemon-reload
  systemctl enable %{service_name}
  systemctl start %{service_name}
fi
# start the service after upgrading
if [ $1 = 2 ] || [ "$1" = "upgrade" ]; then
  systemctl start %{service_name}
fi

%preun
echo preun $1
if [ $1 = 0 ] || [ "$1" = "remove" ]; then
  systemctl stop %{service_name}
  systemctl disable %{service_name}
fi

%files
%defattr(-,root,root,-)
/etc/systemd/system/%{service_name}
/opt/sonatype/nexus3
%dir %config(noreplace) /opt/sonatype/nexus3/extra
%dir %config(noreplace) /opt/sonatype/nexus3/etc
%config(noreplace) /opt/sonatype/nexus3/bin/nexus
%config(noreplace) /opt/sonatype/nexus3/bin/nexus.vmoptions
%config /opt/sonatype/nexus3/extra/daemon/%{service_name}
%defattr(-,nexus3,nexus3)
/opt/sonatype/sonatype-work/nexus3

%changelog
* Thu Mar 27 2025 Frank Vissing <lunarfs@hotmail.com>
exclude jdk bin folder from package, soley rely on dependency
* Thu Aug 08 2024 Dan Rollo <drollo@sonatype.com>
require jdk 17.
* Thu Mar 05 2020 Dan Rollo <drollo@sonatype.com>
switch to systemd
* Thu Feb 06 2020 Dan Rollo <drollo@sonatype.com>
add openjdk dependency
* Wed May 29 2019 Dan Rollo <drollo@sonatype.com>
automatically start and stop service daemon as needed during initial install and upgrades
* Tue May 21 2019 Dan Rollo <drollo@sonatype.com>
initial .spec from prior work of Jason Swank, Rick Briganti, Alvin Gunkel
