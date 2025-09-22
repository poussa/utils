#!/bin/bash

# This script installs Kubernetes on Ubuntu 25.04

set -e

echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "Installing required dependencies..."
sudo apt install -y apt-transport-https ca-certificates curl gnupg

echo "Adding Kubernetes signing key..."
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring

echo "Adding Kubernetes repository..."
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly


echo "Updating package list..."
sudo apt update

echo "Installing kubelet, kubeadm, and kubectl..."
sudo apt install -y kubelet kubeadm kubectl

echo "Holding Kubernetes packages at current version..."
sudo apt-mark hold kubelet kubeadm kubectl

echo "Disabling swap (required for Kubernetes)..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "Enabling required kernel modules..."
sudo modprobe overlay
sudo modprobe br_netfilter

echo "Configuring sysctl for Kubernetes networking..."
cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

echo "Kubernetes installation completed. You can now initialize your cluster with 'kubeadm init'."