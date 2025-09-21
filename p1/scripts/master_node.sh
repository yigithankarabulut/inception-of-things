#!/bin/bash
set -e

sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get install -y curl && sudo apt install -y net-tools

export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_EXEC="--bind-address=192.168.56.110 --flannel-iface=eth1"
export K3S_NODE_NAME="ykarabulS"

export KUBECONFIG_MODE="644"

curl -sfL https://get.k3s.io | sh -

while ! sudo systemctl is-active --quiet k3s; do
    echo "K3s is not active yet, waiting..."
    sleep 2
done

echo "K3s is active, continuing..."

sudo k3s kubectl get nodes

sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token
echo "K3s token is saved to /vagrant/node-token"

echo "k3s master setup complete."