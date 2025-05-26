#!/bin/bash
sudo apt-get update
sudo apt-get install -y nmap hydra hping3 traceroute
sudo ip route add 192.168.100.0/24 via 192.168.200.2
sudo ip route add 192.168.50.0/24 via 192.168.200.2