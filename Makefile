# Determine this makefile's path.
# Be sure to place this BEFORE `include` directives, if any.
THIS_FILE := $(lastword $(MAKEFILE_LIST))

APP = nexus-repository-manager

# The app version (as bundled and published by Sonatype)
VERSION ?= $(shell cat version-to-build.txt)

# the name of the original bundle file
#BUNDLE_FILE := $(APP)-$(VERSION)-unix.tar.gz
BUNDLE_FILE := nexus-$(VERSION)-unix.tar.gz

FETCH_URL ?= "http://download.sonatype.com/nexus/3/$(BUNDLE_FILE)"

RHEL_VERSION ?= 7
# The release of the RPM package
PKG_RELEASE ?= 1.el$(RHEL_VERSION)

# The version to assign to the RPM package
PKG_VERSION := $(shell echo $(VERSION) | sed -e 's|-|_|')
DEB_VERSION := $(shell echo $(VERSION) | sed -e 's|-||')

BASEDIR=$(CURDIR)
BUILDDIR ?= $(BASEDIR)/build

RPMDIR := $(BUILDDIR)/rpmbuild

RPM_NAME := $(APP)-$(PKG_VERSION)-$(PKG_RELEASE).noarch.rpm
DEB_NAME := $(APP)_$(DEB_VERSION)-2_all.deb

# create lists of patchfiles and where to install them
patchfiles := $(wildcard patches/*)
dest_patchfiles := $(patsubst patches/%.patch,$(RPMDIR)/SOURCES/$(APP)-$(PKG_VERSION)-%.patch,$(patchfiles))

# rpmbuild subdirectories
rpm_subdirs := $(addprefix $(RPMDIR)/,BUILD SRPMS RPMS SPECS SOURCES)

help:
	@echo 'Usage:                                                 '
	@echo '  make fetch              retrieve bundle from Sonatype'
	@echo '  make populate           `fetch`; populate rpmbuild tree with sources and patches'
	@echo '  make docker             use a docker container to build the RPM'
	@echo '  make docker-all         use docker containers to build the RPM and DEB'
	@echo '  make show-version       displays version to be built '
	@echo '  make show-release       displays release to be built '
	@echo '  make clean              remove generated files       '

clean:
	rm -rf $(BUILDDIR)/*

show-version:
	@echo $(VERSION)

show-release:
	@echo $(PKG_RELEASE)

show-rpm-name:
	@echo $(RPM_NAME)

show-deb-name:
	@echo $(DEB_NAME)

fetch: $(BUILDDIR) $(BUILDDIR)/$(BUNDLE_FILE)

populate: fetch $(rpm_subdirs) $(dest_patchfiles) $(RPMDIR)/SOURCES/$(BUNDLE_FILE) $(RPMDIR)/SPECS/$(APP).spec

rpm: populate $(RPMDIR)/RPMS/noarch/$(RPM_NAME)

rpm-clean:
	rm -rf $(RPMDIR)

build: rpm $(BUILDDIR)/$(RPM_NAME)
ifeq ($(SIGN_RPM),true)
	./rpm/signrpm.sh $(RPM_NAME)
endif


# retrieve the original bundle from FETCH_URL
$(BUILDDIR)/$(BUNDLE_FILE):
	@ echo "fetching bundle from $(FETCH_URL)"
	@ curl -s -L -k -f -o $@ $(FETCH_URL)

# create RPM subdirectories
$(rpm_subdirs):
	mkdir -p $@

# create Source2 tarball (./extra)
#$(RPMDIR)/SOURCES/$(APP)-$(PKG_VERSION)-rpm.tar.gz:
#	tar -cz --exclude .gitignore -f $@ extra

# create Source tarball
$(RPMDIR)/SOURCES/$(APP)-$(PKG_VERSION)-rpm.tar.gz:
	/bin/ls -alhR
	tar -cz --exclude .gitignore -f $@

# copy patches to SOURCES
$(RPMDIR)/SOURCES/$(APP)-$(PKG_VERSION)-%.patch: patches/%.patch
	cp $< $@

# copy original bundle to SOURCES
$(RPMDIR)/SOURCES/$(BUNDLE_FILE):
	cp $(BUILDDIR)/$(BUNDLE_FILE) $@

# create the SPEC file from template
$(RPMDIR)/SPECS/$(APP).spec: rpm/$(APP).spec
	sed \
	-e "s|%%RELEASE%%|$(PKG_RELEASE)|" \
	-e "s|%%VERSION%%|$(PKG_VERSION)|" \
	-e "s|%%BUNDLE_FILE%%|$(BUNDLE_FILE)|" \
	rpm/$(APP).spec > $@

# create the rpm
$(RPMDIR)/RPMS/noarch/$(RPM_NAME):
	rpmbuild --define '_topdir $(RPMDIR)' -bb $(RPMDIR)/SPECS/$(APP).spec

# copy the build RPM to final location
$(BUILDDIR)/$(RPM_NAME): $(RPMDIR)/RPMS/noarch/$(RPM_NAME)
	cp $< $@


# dockerize
docker-all:
	$(MAKE) -f $(THIS_FILE) docker
	$(MAKE) -f $(THIS_FILE) docker-deb

docker: docker-clean
	docker build -f rpm/Dockerfile --tag $(APP)-rpm:$(RHEL_VERSION) .
	docker run --name $(APP)-rpm-$(RHEL_VERSION)-data $(APP)-rpm:$(RHEL_VERSION) echo "data only container"
	@ docker run --volumes-from $(APP)-rpm-$(RHEL_VERSION)-data --rm \
		-e PKG_RELEASE=$(PKG_RELEASE) -e VERSION=$(VERSION) \
                -e RHEL_VERSION=$(RHEL_VERSION) \
                -e GNUPGHOME=$(GNUPGHOME) \
                -e SECRING_GPG_ASC_BASE64=$(value SECRING_GPG_ASC_BASE64) \
                -e GPG_KEY_EMAIL=$(value GPG_KEY_EMAIL) \
                -e GPG_PASSPHRASE=$(value GPG_PASSPHRASE) \
		$(APP)-rpm:$(RHEL_VERSION) make build SIGN_RPM=$(SIGN_RPM)
	docker cp $(APP)-rpm-$(RHEL_VERSION)-data:/data/build/$(RPM_NAME) /tmp/
	cp /tmp/$(RPM_NAME) build/
	docker rm $(APP)-rpm-$(RHEL_VERSION)-data 2>&1 >/dev/null

docker-clean:
	docker inspect $(APP)-rpm-$(RHEL_VERSION)-data >/dev/null 2>&1 && \
		docker rm $(APP)-rpm-$(RHEL_VERSION)-data || \
		true

docker-deb: docker-deb-clean
	docker build -f deb/Dockerfile --tag $(APP)-deb:$(RHEL_VERSION) .
	docker run --name $(APP)-deb-$(RHEL_VERSION)-data $(APP)-deb:$(RHEL_VERSION) echo "deb data only container"
	docker run --volumes-from $(APP)-deb-$(RHEL_VERSION)-data --rm \
                -e RHEL_VERSION=$(RHEL_VERSION) \
                -e DEB_NAME=$(DEB_NAME) \
		$(APP)-deb:$(RHEL_VERSION) fakeroot alien --to-deb --scripts /data/build/$(RPM_NAME)
	docker cp $(APP)-deb-$(RHEL_VERSION)-data:/data/$(DEB_NAME) /tmp/
	cp /tmp/$(DEB_NAME) build/
	docker rm $(APP)-deb-$(RHEL_VERSION)-data 2>&1 >/dev/null

docker-deb-clean:
	docker inspect $(APP)-deb-$(RHEL_VERSION)-data >/dev/null 2>&1 && \
		docker rm $(APP)-deb-$(RHEL_VERSION)-data || \
		true

.PHONY: help clean fetch populate rpm build docker docker-clean docker-deb docker-deb-clean docker-all
