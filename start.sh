#!/bin/sh

if [ $USE_VPN -eq 1 ]; then
  if [ -z $(ip addr | grep tun0) ]; then
    echo "VPN not configured yet"
    sleep 10
    exit 0
  fi
fi

# Update settings with environment variables
if [ $BLOCKLIST_ENABLED -eq 1 ]; then
  sed -i "s/\"blocklist-enabled\":[[:space:]]*[^,]*,/\"blocklist-enabled\": true,/g" /settings.json
else
  sed -i "s/\"blocklist-enabled\":[[:space:]]*[^,]*,/\"blocklist-enabled\": false,/g" /settings.json
fi
sed -i "s/\"rpc-password\":[[:space:]]*\"[^\"]*/\"rpc-password\": \"${RPC_PASSWORD}/g" /settings.json
sed -i "s/\"rpc-username\":[[:space:]]*\"[^\"]*/\"rpc-username\": \"${RPC_USERNAME}/g" /settings.json
sed -i "s/\"rpc-port\":[[:space:]]*[^,]*,/\"rpc-port\": ${RPC_PORT},/g" /settings.json

mv /settings.json /var/lib/transmission/settings.json

# Start cron to watch for updates to port forwarding
crond -s /opt/cron/periodic -c /opt/cron/crontabs -t /opt/cron/cronstamps -L /proc/1/fd/1 -b

/usr/bin/transmission-daemon -f -g /var/lib/transmission
