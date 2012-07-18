#!/bin/sh

USERNAME=$1
RELEASE=$2
PUPPET_DNS_HOST_NAME=$3
SSH_PUBLIC_KEY=$4

MASTER_DNS_DOMAIN_NAME=`dnsdomainname`

#Update SSH public key
mkdir /home/${USERNAME}/.ssh/
mv /tmp/id_rsa.pub /home/${USERNAME}/.ssh/authorized_keys
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh/
chmod -R u=rwX,go= /home/${USERNAME}/.ssh/

#upgrade Puppet master to official repo
cd /tmp
wget http://apt.puppetlabs.com/puppetlabs-release-${RELEASE}.deb
dpkg -i puppetlabs-release-precise.deb
rm puppetlabs-release-precise.deb

#upgrade packages
apt-get update
apt-get -y upgrade

#configure Puppet
echo "server=${PUPPET_DNS_HOST_NAME}.${MASTER_DNS_DOMAIN_NAME}\ndns_alt_names=${PUPPET_DNS_HOST_NAME},${PUPPET_DNS_HOST_NAME}.${MASTER_DNS_DOMAIN_NAME}\n\n[agent]\nserver=${PUPPET_DNS_HOST_NAME}.${MASTER_DNS_DOMAIN_NAME}" >> /etc/puppet/puppet.conf
sed -i "s/START=no/START=yes/g" /etc/default/puppet

#Add crontab job to sign Enpribus OpenNebula nodes automatically
#######################################################################
#TODO: INSECURE--We need to not do this in the future, maybe place a file from node on puppet master and only sign those nodes who have matching files...
#######################################################################
#echo -e "* *\t* * *\troot\tif [ $(puppetca --list|wc -l) -ne 0  ]; then puppetca --sign --all; fi" >> /etc/crontab
mkdir /home/${USERNAME}/enpribus-incoming-nodes/
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/enpribus-incoming-nodes/
echo "* *\t* * *\troot\t for NODEFILE in /home/${USERNAME}/enpribus-incoming-nodes/*; do NODE=\`basename \${NODEFILE}\`; if [ -f \"\${NODEFILE}\" -a \$(puppetca --list|grep \\\"\${NODE}\\\"|wc -l) -ne 0 ]; then puppetca --sign \${NODE}; rm -f \${NODEFILE};fi; done\n" >> /etc/crontab
