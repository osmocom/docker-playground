#!/bin/bash
set +e
set -x

if [[ -z "${DNS_IPADDR}" ]]; then
  echo "env var DNS_IPADDR undefined!"
  exit 1
fi

ASTERISK_CFG_PATH="/etc/asterisk"

echo "nameserver $DNS_IPADDR" > /etc/resolv.conf

#rm -rf "${ASTERISK_CFG_PATH}"
#mkdir -p "${ASTERISK_CFG_PATH}"

#cp -r /etc/asterisk/* "${ASTERISK_CFG_PATH}/"
cp /data/asterisk.conf "${ASTERISK_CFG_PATH}/"
#sed -i "s#/etc/asterisk#${ASTERISK_CFG_PATH}#" "${ASTERISK_CFG_PATH}/asterisk.conf"
cp /data/pjproject.conf "${ASTERISK_CFG_PATH}/"
cp /data/pjsip.conf "${ASTERISK_CFG_PATH}/"
cp /data/manager.conf "${ASTERISK_CFG_PATH}/"
cp /data/logger.conf "${ASTERISK_CFG_PATH}/"
cat /data/extensions.conf >>"${ASTERISK_CFG_PATH}/extensions.conf"

SERVER_NAME="ims.mnc001.mcc238.3gppnetwork.org"
for i in $(seq 30); do
  set -e
  ping -q -c 1 "$SERVER_NAME" && break
  set +e
  echo "[$i] DNS resolution $SERVER_NAME not ready, waiting..."
  sleep 1
done

/usr/sbin/asterisk -C "${ASTERISK_CFG_PATH}/asterisk.conf" -f -g -vvvvv -ddddd
