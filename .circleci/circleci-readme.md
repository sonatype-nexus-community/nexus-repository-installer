CI Debug Notes
================
To validate some circleci stuff, I was able to run a “build locally” using the steps below.
The local build runs in a docker container.

  * (Once) Install circleci client (`brew install circleci`)

  * Convert the “real” config.yml into a self contained (non-workspace) config via:

        circleci config process .circleci/config.yml > .circleci/local-config.yml

  * Run a local build with the following command:
          
        circleci local execute -c .circleci/local-config.yml --job 'build'

    With the above command, operations that cannot occur during a local build will show an error like this:
     
      ```
      ... Error: FAILED with error not supported
      ```
    
      However, the build will proceed and can complete “successfully”, which allows you to verify scripts in your config, etc.
      
      If the build does complete successfully, you should see a happy yellow `Success!` message.

Misc
----

 * APT key renewals - Because we are not using a key server for .deb packages, we have to deal with manually renewing  
   apt GPG keys - (we should investigate using a key server). Meanwhile, here are the steps to manually update our key:

   - Grab the private key and password via lastpass.
   - `gpg --import <private.key>`
   - `gpg --list-keys` and grab the the key id
   - `gpg --edit-key <KEY ID>` then select the key using `key <SUB KEY ID>` and type `expire` then adjust the expiration and then `save`
   - export the public key `gpg --armor --output public.gpg.key --export <KEY ID>`
   - upload to the `community-hosted` raw repo as so `curl -u USERNAME:PASSWORD -X PUT -H "Content-Type: application/pgp-signature" -T public.gpg.key https://repo.sonatype.com/repository/community-hosted/pki/deb-
     gpg/DEB-GPG-KEY-Sonatype.asc`
