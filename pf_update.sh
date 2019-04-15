#!/bin/sh

SETTINGS_PATH="/var/lib/transmission/settings.json"

if [ -e /pf/port ]; then
  NEW_PIAPORT=$(cat /pf/port)
  OLD_PIAPORT=$(cat "${SETTINGS_PATH}" | awk '$1 == "\"peer-port\":" { print $2+0 }')
  if [ "x${NEW_PIAPORT}" != "x${OLD_PIAPORT}" ]; then
    sed -i "s/\"peer-port\":[[:space:]]*[^,]*,/\"peer-port\": ${NEW_PIAPORT},/g" "${SETTINGS_PATH}"
    pkill -HUP transmission-daemon
  fi
fi
