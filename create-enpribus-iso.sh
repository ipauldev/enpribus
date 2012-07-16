#!/bin/sh

UBUNTU_ISO_URI="http://www.ubuntu.com/start-download?distro=server&bits=64&release=lts"

ENPRIBUS_REPO=`dirname $0`
BUILD_DIR=${ENPRIBUS_REPO}/build
DIST_DIR=${ENPRIBUS_REPO}/dist
INCLUDE_DIR=${ENPRIBUS_REPO}/include
INCLUDE_ISO_DIR=${INCLUDE_DIR}/iso
INSTALLER_ISO=${BUILD_DIR}/installer.iso
ENPRIBUS_ISO=${DIST_DIR}/enpribus.iso
INSTALLER_CD=${BUILD_DIR}/installer-cd

#Ensure helper directories exist
if [ ! -d "${BUILD_DIR}" ]; then
	mkdir ${BUILD_DIR}
fi
if [ ! -d "${DIST_DIR}" ]; then
	mkdir ${DIST_DIR}
fi

#Install p7zip if not installed
if [ $(dpkg -l |grep p7zip-full|wc -l) -eq 0 ]; then
	echo "Installing p7zip-full..."
	sudo apt-get -y install p7zip-full || { echo "ERROR: p7zip-full failed to install. Exiting."; exit 1; }
	sudo -k
fi

#Retrieve Ubuntu ISO image if it does not exist
#NOTE: If you wish to bypass the download, simply place the Ubuntu installer in this location manually
if [ ! -f "${INSTALLER_ISO}" ]; then
	echo "Please wait... downloading Ubuntu..."
    wget -O ${INSTALLER_ISO} ${UBUNTU_ISO_URI} || { echo "ERROR: Ubuntu image download has failed. Exiting."; rm -f ${INSTALLER_ISO}; exit 1; }
    echo "Ubuntu image has been downloaded..."
fi

#Extract ISO if CD Build Directory does not exist
if [ ! -d "${INSTALLER_CD}" ]; then
	echo "Please wait... extracting ISO..."
	7z x -O${INSTALLER_CD} ${INSTALLER_ISO}
fi

#Preseed ISO
echo "Please wait... Preseeding ISO..."
rsync -r ${INCLUDE_ISO_DIR}/ ${INSTALLER_CD}/

#TODO Update seed files with user credentials and temporary password??:
#echo "temppassword" | mkpasswd -s -H MD5

#Create new ISO image
echo "Please wait... Creating ISO..."
mkisofs -r -V "enpribus Install CD" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ${ENPRIBUS_ISO} ${INSTALLER_CD} \
	&& echo "ISO Created successfully and is available for installation at:\n${ENPRIBUS_ISO}"

