#!/bin/bash
set +e
set -x

ASTERISK_CFG_PATH="/etc/asterisk"

#rm -rf "${ASTERISK_CFG_PATH}"
#mkdir -p "${ASTERISK_CFG_PATH}"

#cp -r /etc/asterisk/* "${ASTERISK_CFG_PATH}/"
cp /data/asterisk.conf "${ASTERISK_CFG_PATH}/"
#sed -i "s#/etc/asterisk#${ASTERISK_CFG_PATH}#" "${ASTERISK_CFG_PATH}/asterisk.conf"
cp /data/pjsip.conf "${ASTERISK_CFG_PATH}/"
cp /data/manager.conf "${ASTERISK_CFG_PATH}/"
cp /data/logger.conf "${ASTERISK_CFG_PATH}/"
cat /data/extensions.conf >>"${ASTERISK_CFG_PATH}/extensions.conf"

/usr/sbin/asterisk -C "${ASTERISK_CFG_PATH}/asterisk.conf" -f -g -vvvvv -ddddd
