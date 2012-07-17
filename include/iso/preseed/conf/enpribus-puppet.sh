#!/bin/sh

USERNAME=$1
SSH_KEY=$2
RELEASE=$3

DNS_HOST_NAME=`hostname`
DNS_DOMAIN_NAME=`dnsdomainname`

#Update SSH public key
mkdir /home/${USERNAME}/.ssh/
echo "${SSH_KEY}" > /home/${USERNAME}/.ssh/authorized_keys
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
echo -e "server=${DNS_HOST_NAME}.${DNS_DOMAIN_NAME}\ndns_alt_names=${DNS_HOST_NAME},puppet.${DNS_DOMAIN_NAME}\n\n[agent]\nserver=${DNS_HOST_NAME}.${DNS_DOMAIN_NAME}" >> /etc/puppet/puppet.conf
/etc/init.d/puppet stop
/etc/init.d/puppetmaster stop
rm -Rf /var/lib/puppet/ssl/
