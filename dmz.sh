#!/bin/bash
sudo apt-get update
echo "Instalando Apache2"
sudo apt-get install -y apache2 openssh-server
sudo apache2 -v
sudo ip route add 192.168.200.0/24 via 192.168.100.2
sudo ip route add 192.168.50.0/24 via 192.168.100.2