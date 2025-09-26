SUDO="sudo"
APT="$SUDO apt-get"
APT_UPDATE="$APT update"
APT_UPGRADE="$APT upgrade"
APT_INSTALL="$APT install -y"

function has_command()
{
    local CMD=$1

    if command -v $CMD >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function install_curl()
{
    if ! has_command curl; then
        $SUDO apt-get install -y curl
    fi
}

function install_docker()
{
    if ! has_command docker; then

        echo "Installing Docker..."

        $SUDO install -m 0755 -d /etc/apt/keyrings
        $SUDO curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
        $SUDO chmod a+r /etc/apt/keyrings/docker.asc

        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null
        $APT_UPDATE
        $APT_INSTALL docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        echo "Docker installed."

    fi
}

function install_kubectl()
{
    if ! has_command kubectl; then

        echo "Installing Kubectl..."

        curl -LO "https://dl.k8s.io/release/v1.33.0/bin/linux/amd64/kubectl"
        chmod +x kubectl 
        $SUDO mv kubectl /usr/local/bin/

        echo "Kubectl installed."

    fi
}

function install_k3d()
{
    if ! has_command k3d; then

        echo "Installing K3d..."

        curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

        echo "K3d installed."

    fi
}

function install_argocd()
{
    if ! has_command argocd; then

        echo "Installing ArgoCD..."

        local ARGOCD_VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

        curl -sSL -o argocd "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64"
        chmod +x argocd
        $SUDO mv argocd /usr/local/bin/

        echo "ArgoCD installed."

    fi
}

function install_vagrant()
{
    if ! has_command vagrant; then

        echo "Installing Vagrant..."

        wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        $APT_UPDATE
        $APT_INSTALL vagrant

        echo "Vagrant installed."

    fi
}

function install_virtualbox()
{
    if ! has_command virtualbox; then

        echo "Installing VirtualBox..."

        # Download and add Oracle VirtualBox GPG key
        wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor
        
        # Add VirtualBox repository to sources.list
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian bookworm contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
        
        # Update package list and install VirtualBox 7.0
        sudo apt-get update
        sudo apt-get install virtualbox-7.0

        echo "VirtualBox installed."

    fi
}

install_curl
install_docker
install_kubectl
install_k3d
install_argocd
install_vagrant
install_virtualbox
