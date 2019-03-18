# transmission-docker
Because the world needs another transmission docker container

Super simple transmission setup. To work with a VPN, use docker-compose something like this:

```
services:
  vpn:
    image: your-favourite-vpn-container
    container_name: vpn
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
    network_mode: bridge
    environment:
      - USER=This
      - PASSWORD=Is
      - PROTOCOL=Based
      - ENCRYPTION=On
      - REGION=PIA
      - EXTRA_SUBNETS=B
      - BLOCK_MALICIOUS=ATCH
    restart: unless-stopped
    volumes:
# Here's hoping your VPN container can write out the port it's forwarding to /pf/port 
      - port-forward:/pf:rw

  transmission:
    image: corvustkodi/transmission
    container_name: transmission
    depends_on:
      - vpn
    environment:
      TZ: 'EST5EDT'
      - USE_VPN=1
      - RPC_PORT=8880
    network_mode: "service:vpn"
    restart: unless-stopped
    volumes:
      - /home/user/Torrent-Downloads:/Torrent-Downloads
      - /home/user/Torrent-Incomplete:/Torrent-Incomplete
      - /home/user/Torrent-Var:/var/lib/transmission
      - port-forward:/pf:ro
# It touches a file named with the torrent ID on a complete download - useful for other purposes...
      - done-torrents:/done-torrents
  web:
    image: nginx:alpine
    container_name: torrent_web
    depends_on:
      - transmission
    links:
      - transmission
    environment:
      TZ: 'EST5EDT'
    network_mode: bridge
    ports:
      - 8880:8880
    restart: unless-stopped
    volumes:
# Use some proxy_pass magic in here 
      - ./nginx.conf:/etc/nginx/nginx.conf:ro

networks:
  default:
      
volumes:
  port-forward:
  done-torrents:

```
