#!/bin/sh

UBUNTU_ISO_URI="http://www.ubuntu.com/start-download?distro=server&bits=64&release=lts"
UBUNTU_ISO_PRESEED_URI="https://help.ubuntu.com/12.04/installation-guide/example-preseed.txt"
UBUNTU_RELEASE=precise

#Puppet master Hostname
PUPPET_DNS_HOST_NAME=puppet

#User Account
ENPRIBUS_USER=`id -nu`

#SSH Keys
MY_PRIVATE_KEY_PATH=~/.ssh/id_rsa
MY_PUBLIC_KEY_PATH=~/.ssh/id_rsa.pub

#Primary Paths
ENPRIBUS_REPO=`dirname $0`
BUILD_DIR=${ENPRIBUS_REPO}/build
DIST_DIR=${ENPRIBUS_REPO}/dist

#Include Directory Paths
INCLUDE_DIR=${ENPRIBUS_REPO}/include
INCLUDE_ISO_DIR=${INCLUDE_DIR}/iso
INCLUDE_ISO_PRESEED=${INCLUDE_ISO_DIR}/preseed

#Downloaded Files Paths
INSTALLER_ISO=${BUILD_DIR}/installer.iso
EXAMPLE_PRESEED=${BUILD_DIR}/example-preseed.txt

#Distribution ISO Path
ENPRIBUS_ISO=${DIST_DIR}/enpribus.iso

#Working Dir for New CD
INSTALLER_CD=${BUILD_DIR}/installer-cd

#Preseed working paths
INSTALLER_CD_PRESEED=${INSTALLER_CD}/preseed
INSTALLER_CD_PRESEED_CONF=${INSTALLER_CD_PRESEED}/conf
INSTALLER_CD_PRESEED_OS=${INSTALLER_CD_PRESEED}/ubuntu-server.seed

#Customized Preseed Files
INSTALLER_CD_PRESEED_ENPRIBUS_OPENNEBULA=${INSTALLER_CD_PRESEED}/enpribus-opennebula.seed
ISO_PRESEED_ENPRIBUS_OPENNEBULA=${INCLUDE_ISO_PRESEED}/enpribus-opennebula.seed

INSTALLER_CD_PRESEED_ENPRIBUS_PUPPET=${INSTALLER_CD_PRESEED}/enpribus-puppet.seed
ISO_PRESEED_ENPRIBUS_PUPPET=${INCLUDE_ISO_PRESEED}/enpribus-puppet.seed

#Path for credentials
CREDENTIALS=${DIST_DIR}/credentials.txt

#sed replace with and escape special characters
sed_escape_replace () {
  sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

#Ensure helper directories exist
if [ ! -d "${BUILD_DIR}" ]; then
	mkdir ${BUILD_DIR}
fi
if [ ! -d "${DIST_DIR}" ]; then
	mkdir ${DIST_DIR}
fi

#Install whois if not installed
if [ $(dpkg -l |grep whois|wc -l) -eq 0 ]; then
	echo "Installing whois.."
	sudo apt-get -y install whois || { echo "ERROR: whois failed to install. Exiting."; exit 1; }
fi

#Install p7zip if not installed
if [ $(dpkg -l |grep p7zip-full|wc -l) -eq 0 ]; then
	echo "Installing p7zip-full..."
	sudo apt-get -y install p7zip-full || { echo "ERROR: p7zip-full failed to install. Exiting."; exit 1; }
fi

sudo -k

#Generate SSH key if it does not exist
if [ ! -f "${MY_PRIVATE_KEY_PATH}" ]; then
	echo "Generating SSH Keys..."
	mkdir -p ~/.ssh ; chmod 700 ~/.ssh; ssh-keygen -t rsa -q -f ~/.ssh/id_rsa -N '' || { echo "ERROR: SSH Key generation failed. Exiting."; exit 1; }
fi

#Retrieve Ubuntu ISO image if it does not exist
#NOTE: If you wish to bypass the download, simply place the Ubuntu installer in this location manually
if [ ! -f "${INSTALLER_ISO}" ]; then
	echo "Please wait... downloading Ubuntu..."
    wget -O ${INSTALLER_ISO} ${UBUNTU_ISO_URI} || { echo "ERROR: Ubuntu image download has failed. Exiting."; rm -f ${INSTALLER_ISO}; exit 1; }
    echo "Ubuntu image has been downloaded..."
fi

#Retrieve Ubuntu ISO example preseed file if it does not exist
#NOTE: If you wish to bypass the download, simply place the example preseed in this location manually
if [ ! -f "${EXAMPLE_PRESEED}" ]; then
	echo "Please wait... downloading Ubuntu..."
    wget --no-check-certificate -O ${EXAMPLE_PRESEED} ${UBUNTU_ISO_PRESEED_URI} || { echo "ERROR: Ubuntu example preseed download has failed. Exiting."; rm -f ${EXAMPLE_PRESEED}; exit 1; }
    echo "Ubuntu example preseed has been downloaded..."
fi

#Extract ISO if CD Build Directory does not exist
if [ ! -d "${INSTALLER_CD}" ]; then
	echo "Please wait... extracting ISO..."
	7z x -O${INSTALLER_CD} ${INSTALLER_ISO}
fi

#Preseed ISO
echo "Please wait... Preseeding ISO..."
rsync -r ${INCLUDE_ISO_DIR}/ ${INSTALLER_CD}/

#Create custom preseed files
cat ${EXAMPLE_PRESEED} > ${INSTALLER_CD_PRESEED_ENPRIBUS_OPENNEBULA}
cat ${INSTALLER_CD_PRESEED_OS} >> ${INSTALLER_CD_PRESEED_ENPRIBUS_OPENNEBULA}
cat ${ISO_PRESEED_ENPRIBUS_OPENNEBULA} >> ${INSTALLER_CD_PRESEED_ENPRIBUS_OPENNEBULA}

cat ${EXAMPLE_PRESEED} > ${INSTALLER_CD_PRESEED_ENPRIBUS_PUPPET}
cat ${INSTALLER_CD_PRESEED_OS} >> ${INSTALLER_CD_PRESEED_ENPRIBUS_PUPPET}
cat ${ISO_PRESEED_ENPRIBUS_PUPPET} >> ${INSTALLER_CD_PRESEED_ENPRIBUS_PUPPET}

cp ${MY_PRIVATE_KEY_PATH} ${INSTALLER_CD_PRESEED_CONF}
cp ${MY_PUBLIC_KEY_PATH} ${INSTALLER_CD_PRESEED_CONF}

#TODO Update seed files with user credentials and temporary password:
TEMP_PASS=`tr -dc "[:alnum:][:punct:]" < /dev/urandom | head -c 10`
TEMP_PASS_HASH=`echo ${TEMP_PASS} | mkpasswd -s -H MD5`

sed_escape_replace "[Enpribus User]" "${ENPRIBUS_USER}" ${INSTALLER_CD_PRESEED_ENPRIBUS_OPENNEBULA}
sed_escape_replace "[Enpribus User]" "${ENPRIBUS_USER}" ${INSTALLER_CD_PRESEED_ENPRIBUS_PUPPET}

sed_escape_replace "[MD5 hash]" "${TEMP_PASS_HASH}" ${INSTALLER_CD_PRESEED_ENPRIBUS_OPENNEBULA}
sed_escape_replace "[MD5 hash]" "${TEMP_PASS_HASH}" ${INSTALLER_CD_PRESEED_ENPRIBUS_PUPPET}

sed_escape_replace "[Ubuntu Release]" "${UBUNTU_RELEASE}" ${INSTALLER_CD_PRESEED_ENPRIBUS_OPENNEBULA}
sed_escape_replace "[Ubuntu Release]" "${UBUNTU_RELEASE}" ${INSTALLER_CD_PRESEED_ENPRIBUS_PUPPET}

sed_escape_replace "[Puppet Master Host]" "${PUPPET_DNS_HOST_NAME}" ${INSTALLER_CD_PRESEED_ENPRIBUS_OPENNEBULA}
sed_escape_replace "[Puppet Master Host]" "${PUPPET_DNS_HOST_NAME}" ${INSTALLER_CD_PRESEED_ENPRIBUS_PUPPET}

#Create new ISO image
echo "Please wait... Creating ISO..."
mkisofs -r -V "enpribus Install CD" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ${ENPRIBUS_ISO} ${INSTALLER_CD} \
	&& { echo "ISO Created successfully and is available for installation at:\n${ENPRIBUS_ISO}" ; \
		echo "\nPlease use the following credentials for the new .iso" ; \
		echo "(also saved in ${CREDENTIALS})" ; \
		echo "Username: ${ENPRIBUS_USER}" ; \
		echo "Password: ${TEMP_PASS}" ; \
		echo "Username: ${ENPRIBUS_USER}\nPassword: ${TEMP_PASS}" > ${CREDENTIALS} ; \
	}
