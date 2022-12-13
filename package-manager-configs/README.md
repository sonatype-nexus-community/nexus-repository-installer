The files in this [package-manager-configs](.) folder should be deployed 
to the associated repository.
The deployment of these files is a one-time operation.
These files make it easier for users to set up their local machine to use our installer repositories.

Production: The [production](nx-prod) files have been deployed to [repo.sonatype.com](https://repo.sonatype.com)
in the `community-hosted` raw repository.

#### Original GPG key generation

1. Generation (mac os):
    ```shell
    $ gpg --gen-key
    gpg (GnuPG) 2.2.19; Copyright (C) 2019 Free Software Foundation, Inc.
    ...
    Real name: Sonatype Community PGP
    Email address: community-group@sonatype.com
    You selected this USER-ID:                 
        "Sonatype Community PGP <community-group@sonatype.com>"
    ...
    gpg: revocation certificate stored as '/.../.gnupg/openpgp-revocs.d/80900DA1952D7C7968F3CFD98C79C4D0382A0E3A.rev'
    public and secret key created and signed.
    
    pub   rsa2048 2020-05-01 [SC] [expires: 2022-05-01]
          80900DA1952D7C7968F3CFD98C79C4D0382A0E3A
    uid                      Sonatype Community PGP <community-group@sonatype.com>
    sub   rsa2048 2020-05-01 [E] [expires: 2022-05-01]    
    ```
   Remember to securely store the password and revoke-cert.rev.txt

2. Publish the key (see update notes for current command):
    ```shell
    $ gpg --keyserver hkp://yaddayadda --send-keys 80900DA1952D7C7968F3CFD98C79C4D0382A0E3A
    gpg: sending key 8C79C4D0382A0E3A to hkp://yaddayadda
    ```

#### Updating Expired GPG key

The GPG key used to sign rpms will eventually expire and need to be renewed.
First, sanity check your local key store via:
```shell
$ gpg --list-keys
...
pub   rsa2048 2020-05-01 [SC] [expires: 2024-05-17]
      80900DA1952D7C7968F3CFD98C79C4D0382A0E3A
uid           [ultimate] Sonatype Community PGP <community-group@sonatype.com>
sub   rsa2048 2020-05-01 [E] [expires: 2024-05-17]
...
```
You might need to import the GPG key to your local keystore. The steps below show how to update
and republish the *Sonatype Community PGP* key. 

1. Update the key.
    ```shell
    $ gpg --edit-key 80900DA1952D7C7968F3CFD98C79C4D0382A0E3A
    gpg (GnuPG) 2.3.4; Copyright (C) 2021 Free Software Foundation, Inc.
    ...
    sec  rsa2048/8C79C4D0382A0E3A
         created: 2020-05-01  expired: 2022-05-01  usage: SC  
         trust: ultimate      validity: expired
    ssb  rsa2048/23A79D104345474C
         created: 2020-05-01  expired: 2022-05-01  usage: E   
    [ expired] (1). Sonatype Community PGP <community-group@sonatype.com>
    
    gpg> 1
    
    sec  rsa2048/8C79C4D0382A0E3A
         created: 2020-05-01  expired: 2022-05-01  usage: SC  
         trust: ultimate      validity: expired
    ssb  rsa2048/23A79D104345474C
         created: 2020-05-01  expired: 2022-05-01  usage: E   
    [ expired] (1)* Sonatype Community PGP <community-group@sonatype.com>
    
    gpg> expire
    Changing expiration time for the primary key.
    Please specify how long the key should be valid.
             0 = key does not expire
          <n>  = key expires in n days
          <n>w = key expires in n weeks
          <n>m = key expires in n months
          <n>y = key expires in n years
    Key is valid for? (0) 2y
    Key expires at Fri May 17 16:45:08 2024 EDT
    Is this correct? (y/N) y
    
    sec  rsa2048/8C79C4D0382A0E3A
         created: 2020-05-01  expires: 2024-05-17  usage: SC  
         trust: ultimate      validity: ultimate
    ssb  rsa2048/23A79D104345474C
         created: 2020-05-01  expired: 2022-05-01  usage: E   
    [ultimate] (1)* Sonatype Community PGP <community-group@sonatype.com>
    
    gpg: WARNING: Your encryption subkey expires soon.
    gpg: You may want to change its expiration date too.
    gpg> save
    ```
2. Publish the updated key:
    ```shell
    gpg --keyserver pgp.mit.edu --send-keys 80900DA1952D7C7968F3CFD98C79C4D0382A0E3A
    gpg: sending key 8C79C4D0382A0E3A to hkp://pgp.mit.edu
    
    gpg --keyserver keyserver.ubuntu.com --send-keys 80900DA1952D7C7968F3CFD98C79C4D0382A0E3A
    gpg: sending key 8C79C4D0382A0E3A to hkp://keyserver.ubuntu.com
    ```
3. To use the updated key for rpm signing during CI builds, you need to export the private key 
  in base64 (e.g. CircleCI env var: SECRING_GPG_ASC_BASE64). Use the key id (not email address)
  when exporting.
    ```shell
    gpg --no-default-keyring --armor --export-secret-key 80900DA1952D7C7968F3CFD98C79C4D0382A0E3A | base64
    ```
    Securely store this value.

4. Update the public key files in our public repository. 
   1. Export the public key. Use the key id (not email address) when exporting.
      ```shell
      gpg --output RPM-GPG-KEY-Sonatype.asc --armor --export 80900DA1952D7C7968F3CFD98C79C4D0382A0E3A
      ```
   2. Upload that file to the [community-hosted](https://repo.sonatype.com/#browse/browse:community-hosted) raw repository,
   specifically: 
   
     * [comunity-hosted/pki/rpm-gpg/RPM-GPG-KEY-Sonatype.asc](https://repo.sonatype.com/#browse/browse:community-hosted:pki%2Frpm-gpg%2FRPM-GPG-KEY-Sonatype.asc)
     * [comunity-hosted/pki/deb-gpg/DEB-GPG-KEY-Sonatype.asc](https://repo.sonatype.com/#browse/browse:community-hosted:pki%2Fdeb-gpg%2FDEB-GPG-KEY-Sonatype.asc)
5. Update the private signing key in the Apt repository configuration of Nexus Repository Manager.
   You will need the PGP key password for this step. The command below will put the private key
   into your clipboard, so you can paste it into the Nexus Repository Manager Apt config *Signing Key* field.
   ```shell
   gpg --no-default-keyring --armor --export-secret-key 80900DA1952D7C7968F3CFD98C79C4D0382A0E3A | pbcopy
   ```
   Put the passphrase for the above private signing key into the *Passphrase* field of Nexus Repository Manager Apt config.
