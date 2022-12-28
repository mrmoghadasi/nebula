# vim update_nebula.sh
#!/bin/bash
systemctl stop nebula

NEBULA_DIR=/etc/nebula
NEBULA_VER=v$(curl -sL https://api.github.com/repos/slackhq/nebula/releases/latest | grep "tag_name"   | sed -E 's/.*"([^"]+)".*/\1/'|sed 's/v//')


cd $NEBULA_DIR && rm -f nebula-linux-amd64.tar.gz


#downlad and copy binary files to proper location
echo "downlad and copy binary files to proper location "
wget -c -O  $NEBULA_DIR/nebula-linux-amd64.tar.gz https://github.com/slackhq/nebula/releases/download/$NEBULA_VER/nebula-linux-amd64.tar.gz
sleep 2
cd $NEBULA_DIR && tar -xavf nebula-linux-amd64.tar.gz
sleep 2
cd $NEBULA_DIR && cp -av nebula /usr/local/bin/nebula && chmod +x /usr/local/bin/nebula
echo "Done"

systemctl daemon-reload
systemctl start nebula
systemctl status nebula
