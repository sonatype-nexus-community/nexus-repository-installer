#!/bin/bash

check_errs()
{
  # Function. Parameter 1 is the return code
  # Para. 2 is text to display on failure.
  if [ "${1}" -ne "0" ]; then
    echo "ERROR # ${1} : ${2}"
    # as a bonus, make our script exit with the right error code.
    exit ${1}
  fi
}

echo Sign rpm script running

if [ -z ${SECRING_GPG_ASC_BASE64+x} ]; then
  echo "SECRING_GPG_ASC_BASE64 is unset, skipping rpm signing";
else
  echo "SECRING_GPG_ASC_BASE64 var is set, attempting to sign rpm";

  echo "GNUPGHOME: ${GNUPGHOME}"

  mkdir -p build/rpm-signing-keys/uhome
  check_errs $? "Unable to create key dirs"

  chmod 700 build/rpm-signing-keys/uhome
  check_errs $? "Unable to set gpg dir permissions"

  echo ${SECRING_GPG_ASC_BASE64} | base64 --decode | gpg --batch --no-tty --import --yes
  check_errs $? "Unable to create key file"

  export RPM_NAME=$1
  echo "RPM_NAME: ${RPM_NAME}"

  #echo $GPG_PASSPHRASE | rpmsign -D "_gpg_name ${GPG_KEY_EMAIL}" --addsign build/${RPM_NAME}
  ./rpm/rpm-sign.exp "build/${RPM_NAME}"
  check_errs $? "Unable to sign rpm: build/${RPM_NAME}"

  # todo Add check of rpm key after importing public key...maybe
  #rpm -K build/${RPM_NAME}
  #check_errs $? "Unable to check rpm key"
  # at least make sure output of rpm -K includes "PGP"
  RPM_KEY_CHECK_RESULT=$(rpm -K build/${RPM_NAME})
  echo "RPM_KEY_CHECK_RESULT: ${RPM_KEY_CHECK_RESULT}"
  if [[ ${RPM_KEY_CHECK_RESULT} != *"PGP"* ]];then
    check_errs 1 "RPM not signed with PGP key"
  fi

  #rm -rf build/rpm-signing-keys
  #check_errs $? "Unable to remove key dirs"
fi

echo Done sign rpm script
