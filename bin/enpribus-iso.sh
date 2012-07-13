#!/bin/sh

echo "" > .ssh/known_hosts
sudo mkisofs -r -V "enpribus Install CD" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o enpribus.iso ubuntu-12.04-server-amd64
