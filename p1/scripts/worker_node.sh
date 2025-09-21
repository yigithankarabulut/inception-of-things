#!/bin/bash
set -e

sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get install -y curl && sudo apt install -y net-tools

# Wait for master node token
while [ ! -f /vagrant/node-token ]; do
    echo "Waiting for master node token..."
    sleep 5
done

TOKEN=$(cat /vagrant/node-token)
SERVER_IP="192.168.56.110"

export K3S_URL="https://$SERVER_IP:6443"
export K3S_TOKEN="$TOKEN"
export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_EXEC="agent --node-ip=192.168.56.111 --flannel-iface=eth1"
export K3S_NODE_NAME="ykarabulSW"

export KUBECONFIG_MODE="644"

curl -sfL https://get.k3s.io | sh -

while ! sudo systemctl is-active --quiet k3s-agent; do
    echo "K3s agent is not active yet, waiting..."
    sleep 2
done

echo "k3s worker setup complete."