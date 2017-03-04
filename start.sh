#!/bin/bash

/usr/bin/vncserver

/usr/sbin/xrdp --port 3389



firewall-cmd --permanent --zone=public --add-port=3389/tcp
firewall-cmd --permanent --zone=public --add-port=5901/tcp
firewall-cmd --permanent --zone=public --add-port=3350/tcp
firewall-cmd --reload

chcon --type=bin_t /usr/sbin/xrdp
chcon --type=bin_t /usr/sbin/xrdp-sesman

# run ssh
/usr/sbin/sshd -D
echo "done"
