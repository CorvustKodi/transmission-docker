#!/bin/sh

SETTINGS=/etc/transmission/settings.json

if [ $USE_VPN -eq 1 ]; then
  if [ -z $(ip addr | grep tun0) ]; then
    echo "VPN not configured yet"
    sleep 10
    exit 0
  fi
fi

# Update settings with environment variables
if [ $BLOCKLIST_ENABLED -eq 1 ]; then
  sed -i "s/\"blocklist-enabled\":[[:space:]]*[^,]*,/\"blocklist-enabled\": true,/g" $SETTINGS
else
  sed -i "s/\"blocklist-enabled\":[[:space:]]*[^,]*,/\"blocklist-enabled\": false,/g" $SETTINGS
fi
if [ ! -z $SPEED_LIMIT_UP ]; then
  sed -i "s/\"speed-limit-up\":[[:space:]]*[^,]*,/\"speed-limit-up\": ${SPEED_LIMIT_UP},/g" $SETTINGS
  sed -i "s/\"speed-limit-up-enabled\":[[:space:]]*[^,]*,/\"speed-limit-up-enabled\": true,/g" $SETTINGS
fi
if [ ! -z $SPEED_LIMIT_DOWN ]; then
  sed -i "s/\"speed-limit-down\":[[:space:]]*[^,]*,/\"speed-limit-down\": ${SPEED_LIMIT_DOWN},/g" $SETTINGS
  sed -i "s/\"speed-limit-down-enabled\":[[:space:]]*[^,]*,/\"speed-limit-down-enabled\": true,/g" $SETTINGS
fi
sed -i "s/\"rpc-password\":[[:space:]]*\"[^\"]*/\"rpc-password\": \"${RPC_PASSWORD}/g" $SETTINGS
sed -i "s/\"rpc-username\":[[:space:]]*\"[^\"]*/\"rpc-username\": \"${RPC_USERNAME}/g" $SETTINGS
sed -i "s/\"rpc-port\":[[:space:]]*[^,]*,/\"rpc-port\": ${RPC_PORT},/g" $SETTINGS

# Start cron to watch for updates to port forwarding
crond -s /opt/cron/periodic -c /opt/cron/crontabs -t /opt/cron/cronstamps -L /proc/1/fd/1 -b

/usr/bin/transmission-daemon -f -g /etc/transmission
