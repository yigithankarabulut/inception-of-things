#! /bin/bash

# Update and install necessary packages
sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get install -y curl && sudo apt install -y net-tools

# K3s server arguments
NODE_IP="--node-ip=$1"
BIND_ADDRESS="--bind-address=$1"
FLANNEL_IFACE="--flannel-iface=eth1"
export K3S_NODE_NAME="ykarabulS"
export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_EXEC="$NODE_IP $BIND_ADDRESS $FLANNEL_IFACE"

# Install K3s server
echo "Installing K3s server....."
curl -sfL https://get.k3s.io | sh -

# Wait for master node to be ready
echo "Waiting for master node to be ready..."
while ! sudo systemctl is-active --quiet k3s; do
    echo "K3s is not active yet, waiting..."
    sleep 2
done

# Get nodes for waiting for worker nodes to be ready
sudo k3s kubectl get nodes

echo "Master node is ready! Deploying applications..."

# Deploy applications
i=1
while [ $i -le 3 ]
do 
    echo "Deploying app$i..."
    sudo k3s kubectl apply -f /vagrant/manifests/app$i.yml
    i=$((i + 1))
done

# Deploy ingress
echo "Deploying ingress..."
sudo k3s kubectl apply -f /vagrant/manifests/ingress.yml

echo "k3s master setup complete."