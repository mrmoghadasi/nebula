#!/bin/bash
NEBULA_DIR=/etc/nebula
NEBULA_VER=v$(curl -sL https://api.github.com/repos/slackhq/nebula/releases/latest | grep "tag_name"   | sed -E 's/.*"([^"]+)".*/\1/'|sed 's/v//')

# create directory and change directoy to it
echo "create directory and change directoy to it"
mkdir -p $NEBULA_DIR
echo "Done"

#install needed packages
echo "install needed packages"
apt-get update && apt-get install wget curl -y
echo "Done"
sleep 2
#downlad and copy binary files to proper location
echo "downlad and copy binary files to proper location "
wget -c -O  $NEBULA_DIR/nebula-linux-amd64.tar.gz https://github.com/slackhq/nebula/releases/download/$NEBULA_VER/nebula-linux-amd64.tar.gz
sleep 2
cd $NEBULA_DIR && tar -xavf nebula-linux-amd64.tar.gz
sleep 2
cd $NEBULA_DIR && cp -av nebula /usr/local/bin/nebula && chmod +x /usr/local/bin/nebula
echo "Done"

#create config files
echo "create config files"
cat > $NEBULA_DIR/config.yml << EOF
pki:
  ca: /etc/nebula/ca.crt
  cert: /etc/nebula/client.crt
  key: /etc/nebula/client.key


static_host_map:
  "10.10.10.1": ["ip_lighthouse_1:port"]
  "10.10.10.2": ["ip_lighthouse_2:port"]


lighthouse:
  am_lighthouse: true
  interval: 60
  hosts:

listen:
  host: 0.0.0.0
  port: *
  batch: 64
  read_buffer: 20000000
  write_buffer: 20000000
punchy:
  punch: true
  respond: true
  delay: 1s
cipher: aes
local_range: "10.10.10.0/19"
tun:
  disabled: false
  dev: nebula1
  drop_local_broadcast: false
  drop_multicast: false
  tx_queue: 5000
  mtu: 1300

  routes:
    #- mtu: 8800
    #  route: 10.0.0.0/16
  unsafe_routes:
    #- route: 172.16.1.0/24
    #  via: 192.168.100.99
    #  mtu: 1300 #mtu will default to tun mtu if this option is not sepcified
logging:
  level: info
  format: text
firewall:
  conntrack:
    tcp_timeout: 12m
    udp_timeout: 3m
    default_timeout: 10m
    max_connections: 100000
  outbound:
    # Allow all outbound traffic from this node
    - port: any
      proto: any
      host: any
  inbound:
    # Allow all inbound traffic to this node
    - port: any
      proto: any
      host: any


EOF


echo "Done"

#create service daemon for nebula and start nebula service
echo "create service daemon for nebula and start nebula service"
curl -L -o /etc/systemd/system/nebula.service https://raw.githubusercontent.com/slackhq/nebula/master/examples/service_scripts/nebula.service
echo "Done"

echo "Start the nebula service"
systemctl daemon-reload
systemctl start nebula
systemctl status nebula
