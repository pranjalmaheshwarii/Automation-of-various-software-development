#!/bin/bash

# Update and upgrade the package index
apt-get update -y
apt-get upgrade -y

# Install necessary dependencies
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release unzip

# Install Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Terraform
TERRAFORM_VERSION="1.5.0"  # Change this to the desired version
wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -d /usr/local/bin/
chmod +x /usr/local/bin/terraform
rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# Install Terragrunt
TERRAGRUNT_VERSION="0.47.0"  # Change this to the desired version
wget "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" -O /usr/local/bin/terragrunt
chmod +x /usr/local/bin/terragrunt

# Install kubectl
KUBECTL_VERSION="v1.26.0"  # Change this to the desired version
curl -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install Ansible
apt-get install -y software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible

# Enable and start Docker service
systemctl enable docker
systemctl start docker

echo "Installation completed successfully!"
