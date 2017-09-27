#!/usr/bin/env bash
set -e

sudo iptables -I INPUT -s 0/0 -p tcp --dport 8000 -j ACCEPT
sudo iptables -I INPUT -s 0/0 -p tcp --dport 1522 -j ACCEPT
sudo iptables -I INPUT -s 0/0 -p tcp --dport 22 -j ACCEPT

if [ -d /etc/sysconfig ]; then
  sudo iptables-save | sudo tee /etc/sysconfig/iptables
else
  sudo iptables-save | sudo tee /etc/iptables.rules
fi
