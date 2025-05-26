#!/bin/bash
sudo apt-get update
sudo apt-get install -y samba openssh-server
sudo ip route add 192.168.100.0/24 via 192.168.50.2