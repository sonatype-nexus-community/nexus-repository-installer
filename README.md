About
-----

Package Nexus Repository Manager 3 as an RPM and DEB.

[![CircleCI](https://circleci.com/gh/sonatype-nexus-community/nexus-repository-installer.svg?style=svg)](https://circleci.com/gh/sonatype-nexus-community/nexus-repository-installer)

Usage
--------

Prebuilt binaries of these installers are available from the community 
[Yum](https://nx-staging.sonatype.com/#browse/browse:community-yum-hosted) and 
[Apt](https://nx-staging.sonatype.com/#browse/browse:community-apt-hosted) repositories. 

The [community-hosted](https://nx-staging.sonatype.com/#browse/browse:community-hosted) repository provides example 
Yum configuration (`sonatype-community.repo`) and Apt configuration (`sonatype-community.list`) files, 
and related public keys under the `pki` folder.

#### Yum setup

  1. (One-time setup) If you don't already have JDK 8 installed, then install OpenJDK 8 JDK:
  
         yum install java-1.8.0-openjdk

  2. Copy the Yum configuration file: [sonatype-community.repo](https://nx-staging.sonatype.com/repository/community-hosted/sonatype-community.repo)
     to your `/etc/yum.repos.d/` directory.
  3. Install the application via yum. The first time you use our installer, you will be prompted to install the GPG signing key.

         yum install nexus-repository-manager
              
#### Apt setup

  1. (One-time setup) If you don't already have JDK 8 installed, then install OpenJDK 8 JDK:
  
         sudo apt-get install openjdk-8-jdk

  2. Copy the Apt configuration file: [sonatype-community.list](https://nx-staging.sonatype.com/repository/community-hosted/sonatype-community.list)
     to your `/etc/apt/sources.list.d/` directory.
  3. (One-time setup) Download the [public GPG signing key](https://nx-staging.sonatype.com/repository/community-hosted/pki/deb-gpg/DEB-GPG-KEY-Sonatype.asc)
     and add the key to your apt sources keyring:
     
         wget https://nx-staging.sonatype.com/repository/community-hosted/pki/deb-gpg/DEB-GPG-KEY-Sonatype.asc
         sudo apt-key add DEB-GPG-KEY-Sonatype.asc
  
  4. Install the application via apt-get. The first time you use our installer, you will be prompted to install the GPG signing key.

         sudo apt-get install nexus-repository-manager         

Overview
--------

Make is used to download the application bundle from Sonatype, populate an RPM build
environment, and invoke `rpmbuild`.
You can specify the bundle version to download by setting the `VERSION` environment variable. 
The RPM will be written to `./build`.

The DEB is generated from the RPM using the [alien](https://wiki.debian.org/Alien) command in another docker container.
This is why you will see a number of `elif` commands in the `%pre`, `%post`, and `%preun` sections of the [.spec](rpm/nexus-repository-manager.spec) file,
to ensure the scriptlets work on both distributions. 
The DEB will be written to `./build`. 

Examples:

Build the RPM locally (requires linux tooling).  The RPM will be written to `build/`.

```
$ make build
$ VERSION=3.15.2-01 make rpm
```

Build the RPM in a docker container.  The RPM will be written to `build/`.

```
$ make docker
$ VERSION=3.15.2-01 make docker
```

Build the RPM in a docker container and build the DEB in another container.  The RPM and DEB will be written to `build/`.

```
$ make docker-all
$ VERSION=3.15.2-01 make docker-all
```

Use the `make help` command to see more options.

Tweaks made to the Application
------------------------------

* Software installs to */opt/sonatype/nexus3*.

* The `data directory` is */opt/sonatype/sonatype-work/nexus3*.


Notes/Todo
----------

* ~~Currently, the service daemon (linked to `/etc/init.d/nexus3`) is NOT started after install.~~
  
  ~~Similarly, the service daemon is NOT stopped before upgrade or remove.~~
  
  ~~Therefore, you need to stop/start the service manually. Patches to improve this behavior are welcome!~~
  * Done: The .rpm will now start Nexus Repository Manager after installation, and stop and restart during upgrade.
  
* ~~Add an installer for .deb packaging~~
  * Done: A .deb installer is created by the `make docker-all` command  

* Use `rpmlint` to validate the generated .rpm installer.

* Use `lintian` to validate the generated .deb installer.

## The Fine Print

It is worth noting that this is **NOT SUPPORTED** by Sonatype, and is a contribution to the open source community (read: you!)

Don't worry, using this community item does not "void your warranty". In a worst case scenario, you may be asked 
by the Sonatype Support team to remove the community item in order to determine the root cause of any issues.

Remember:

* Use this contribution at the risk tolerance that you have
* Do **NOT** file Sonatype support tickets with Sonatype support related to this project
* **DO** file issues here on GitHub, so that the community can pitch in

Phew, that was easier than I thought. Last but not least of all:

Have fun building and using this item, we are glad to have you here!

## Getting help

Looking to contribute, but need some help? There's a few ways to get information:

* Chat with us on [Gitter](https://gitter.im/sonatype/nexus-developers)
* Check out the [Nexus3](http://stackoverflow.com/questions/tagged/nexus3) tag on Stack Overflow
* Check out the [Nexus Repository User List](https://groups.google.com/a/glists.sonatype.com/forum/?hl=en#!forum/nexus-users)

## Debugging

* It may be helpful to run the .rpm with debug commands like the one below:

      rpm -ivvh nexus-repository-manager-3.15.2_01-1.el7.noarch.rpm 
      
  This will provide tons of information about what the installer is doing.
  
* CI local debug - you can run a local ci build using the following:

      circleci config process .circleci/config.yml > .circleci/local-config.yml  \
          &&  circleci local execute --config .circleci/local-config.yml --job build
  

## Build Installers via CI

  1. Update the version number in [version-to-build.txt](version-to-build.txt) to the new version to be built. e.g.
  
         3.16.2-01
         
     to:
     
         3.17.0-01

     Commit and push the updated [version-to-build.txt](version-to-build.txt) file to the `master` branch.
     
  2. After a new build has completed, click the `deploy_staging` or `deploy` workflow.

   <!-- @todo Add 'deploy' workflow to deploy to production NXRM3 -->
