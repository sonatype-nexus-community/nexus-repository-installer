About
-----

Package Nexus Repository Manager 3 as an RPM.

Overview
--------

Make is used to download the application bundle from Sonatype, populate an RPM build
environment, and invoke `rpmbuild`.
You can specify the bundle version to download by setting the `VERSION` environment variable 
The RPM will be written to `./build`.

```
$ make build
$ VERSION=3.15.2-01 make rpm
```

Build the RPM in a docker container.  The RPM will be written to `build/`.

```
$ make docker
$ VERSION=3.15.2-01 make docker
```

Use the `make help` command to see more options.

Tweaks made to the Application
------------------------------

* Software installs to */opt/sonatype/nexus3*.

* Patch nexus.properties: The `data directory` is */opt/sonatype/sonatype-work/nexus3*.


Notes/Todo
----------

* Currently, the service daemon (linked to `/etc/init.d/nexus3`) is NOT started after install.
  
  Similarly, the service daemon is NOT stopped before upgrade or remove.
  
  Therefore, you need to stop/start the service manually. Patches to improve this behavior are welcome!  
