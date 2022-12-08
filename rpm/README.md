Misc RPM Notes
==============

Docker image used to build rpm:
-------------------------------

https://github.com/jswank/dockerfiles/blob/master/centos-rpm/Dockerfile.7

```dockerfile
FROM       centos:7
MAINTAINER Jason Swank <docker@scalene.net>

RUN yum -y groupinstall "Development Tools" \
  && yum clean all

RUN yum install -y \
  epel-release rpmdevtools curl tar createrepo \
  && yum clean all
```

https://hub.docker.com/layers/jswank/centos-rpm/7/images/sha256-fa9bdc1296f57eed10f9616dcd762f192128a1cf08fa9e967430ea28260edfb9?context=explore
