#!/bin/sh

USERNAME=$1
SSHKEY=$2

#Update SSH Public Key
mkdir /home/${USERNAME}/.ssh/
echo "${SSHKEY}" > /home/${USERNAME}/.ssh/authorized_keys
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh/
chmod -R u=rwX,go= /home/${USERNAME}/.ssh/

#setup Puppet Master
