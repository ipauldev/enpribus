#!/bin/sh

USERNAME=$1
RELEASE=$2
PUPPET_DNS_HOST_NAME=$3

MASTER_DNS_DOMAIN_NAME=`dnsdomainname`

NODE_HOST_NAME=`hostname`

#Update SSH keys
mkdir /home/${USERNAME}/.ssh/
mv /tmp/id_rsa /home/${USERNAME}/.ssh/id_rsa
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

#Request Puppet master sign node
ssh -o StrictHostKeyChecking=no -i /home/${USERNAME}/.ssh/id_rsa ${USERNAME}@${PUPPET_DNS_HOST_NAME}.${MASTER_DNS_DOMAIN_NAME} touch ./enpribus-incoming-nodes/${NODE_HOST_NAME}.${MASTER_DNS_DOMAIN_NAME}
