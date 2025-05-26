#!/bin/bash
sudo apt-get update
sudo apt-get install -y deamon

echo ""
echo "Configurando reglas iptables"
echo "	Activar reenvío de paquetes entre interfaces"
echo "1" > /proc/sys/net/ipv4/ip_forward
echo "	Limpiar reglas existentes"
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
# echo "	Permitir conexiones desde el HOST Vagrant"
# sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

echo ""
echo "Configurando permisos de INPUT para FIREWALL"
echo "	Permitir tráfico en localhost"
sudo iptables -A INPUT -i lo -j ACCEPT
echo "	Permitir ping hacia firewall"
sudo iptables -A INPUT -p icmp -j ACCEPT
echo "	Permitir SSH desde LAN"
sudo iptables -A INPUT -p tcp -s 192.168.50.10 --dport 22 -j ACCEPT
sudo iptables -A INPUT -i eth2 -p tcp -s 192.168.50.10 --dport 22 -j ACCEPT
echo "	Permitir respuestas de conexiones establecidas"
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

echo ""
echo "Configurando permisos de FORWARD en general"
echo "	Permitir PING desde LAN hacia DMZ"
sudo iptables -A FORWARD -i eth2 -o eth1 -s 192.168.50.0/24 -d 192.168.100.10 -p tcp --dport 22 -j ACCEPT
echo "	Permitir CURL y SSH desde LAN hacia DMZ"
sudo iptables -A FORWARD -i eth2 -o eth1 -s 192.168.50.0/24 -d 192.168.100.10 -p icmp -j ACCEPT
sudo iptables -A FORWARD -i eth2 -o eth1 -s 192.168.50.0/24 -d 192.168.100.10 -p tcp --dport 80 -j ACCEPT
echo "	Permitir SSH desde red exterior (simulado subred 200)"
sudo iptables -A FORWARD -i eth1 -o eth1 -s 192.168.200.0/24 -d 192.168.100.10 -p tcp --dport 22 -j ACCEPT
echo "	Permitir respuesta desde DMZ"
sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
echo "	Permitir PING desde cualquier origen hacia DMZ"
sudo iptables -A FORWARD -i eth3 -o eth1 -s 192.168.200.0/24 -d 192.168.100.0/24 -p icmp -j ACCEPT
echo "	Permitir CURL, SSH y SCANs desde cualquier origen hacia DMZ"
sudo iptables -A FORWARD -i eth3 -o eth1 -s 192.168.200.0/24 -d 192.168.100.0/24 -p tcp --dport 22 -j ACCEPT
sudo iptables -A FORWARD -i eth3 -o eth1 -s 192.168.200.0/24 -d 192.168.100.0/24 -p tcp --dport 80 -j ACCEPT
echo "	Denegar SSH desde cualquier origen hacia LAN"
sudo iptables -A FORWARD -p tcp -d 192.168.50.0/24 --dport 22 -m limit --limit 1/s -j LOG --log-prefix "SYN SCAN LAN SSH: "
sudo iptables -A FORWARD -p tcp -d 192.168.100.0/24 --dport 22 --syn -m limit --limit 1/s -j LOG --log-prefix "SSH FLOOD: "
sudo iptables -A FORWARD -p tcp -d 192.168.50.0/24 --dport 22 -j DROP
echo "	Denegar PING, SSH y SCAN desde cualquier origen hacia LAN"
sudo iptables -A FORWARD -s 192.168.100.0/24 -d 192.168.50.0/24 -j DROP
sudo iptables -A FORWARD -s 192.168.200.0/24 -d 192.168.50.0/24 -j DROP


echo ""
echo "Configurando permisos de INPUT en general"
echo "	Detectar y registrar escaneos SYN, NULL, XMAS y FIN desde cualquier origen hacia firewall"
sudo iptables -A INPUT -p tcp --tcp-flags ALL SYN -m limit --limit 1/s -j LOG --log-prefix "SYN SCAN: "
sudo iptables -A INPUT -p tcp --tcp-flags ALL NONE -m limit --limit 1/s -j LOG --log-prefix "NULL SCAN: "
sudo iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -m limit --limit 1/s -j LOG --log-prefix "XMAS SCAN: "
sudo iptables -A INPUT -p tcp --tcp-flags ALL FIN -m limit --limit 1/s -j LOG --log-prefix "FIN SCAN: "
echo "	Denegar escaneos SYN, NULL, XMAS y FIN desde cualquier origen hacia firewall"
sudo iptables -A INPUT -p tcp --tcp-flags ALL SYN -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags ALL FIN -j DROP
echo "	Registrar cualquier paquete no capturado por reglas anteriores"
sudo iptables -A INPUT -j LOG --log-prefix "INPUT DROP: "
sudo iptables -A FORWARD -j LOG --log-prefix "FORWARD DROP: "

echo ""
echo "Agregando reglas por defecto"
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

echo ""
echo "La configuración del firewall ha finalizado con éxito"
echo ""