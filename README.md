About
-----

Package Nexus Repository Manager 3 as an RPM and DEB.

Overview
--------

Make is used to download the application bundle from Sonatype, populate an RPM build
environment, and invoke `rpmbuild`.
You can specify the bundle version to download by setting the `VERSION` environment variable. 
The RPM will be written to `./build`.

The DEB is generated from the RPM using the [alien](https://wiki.debian.org/Alien) command in another docker container.
This is why you will see a number of `elif` commands in the `%pre`, `%post`, and `%preun` sections of the [.spec](nexus-repository-manager.spec) file,
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

## Archive

The `archive` branch contains some prebuilt installer binaries. These are tracked using [git lfs](https://git-lfs.github.com)
to ensure a clone of the project does not get crazy huge. Follow the steps below to add a new version to the archive
branch:

  1. Update the `Makefile` default VERSION value to the new version to be archived. e.g.
  
         VERSION ?= 3.16.2-01
         
     to:
     
         VERSION ?= 3.17.0-01

     Commit the updated `Makefile` to `master`.
     
  2. Build the new installers via:
  
         make docker-all
         
  3. Checkout and pull the `archive` branch, copy the new installers to the `archive` folder. 
     
     `git add` the new installers in the `archive` folder.
     
     Lock new installer archive files.
     
     (Optional) Sanity check that the new installers are showing in the lfs files list.
     
     Commit the changes and push. The push will take a long time.

         git checkout archive
         git pull
         
         cp build/nexus-repository-manager-3.17.0_01-1.el7.noarch.rpm archive/
         cp build/nexus-repository-manager_3.17.001-2_all.deb archive/
         
         git add archive/nexus-repository-manager-3.17.0_01-1.el7.noarch.rpm
         git add archive/nexus-repository-manager_3.17.001-2_all.deb 
         
         git lfs lock archive/nexus-repository-manager-3.17.0_01-1.el7.noarch.rpm
         git lfs lock archive/nexus-repository-manager_3.17.001-2_all.deb

         git lfs ls-files
         
         git commit -m 'archive version 3.17.0_01'
         git push

  4. Checkout the `master` branch.
