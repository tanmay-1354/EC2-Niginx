#!/bin/bash
set -e

# ==============================
# CHANGE THESE PER EC2 INSTANCE
# ==============================
INSTANCE_DOMAIN=""
DOCKER_DOMAIN=""

# Example:
# EC2-1:
# INSTANCE_DOMAIN="ec2-instance1.devops-sam.rest"
# DOCKER_DOMAIN="ec2-docker1.devops-sam.rest"
#
# EC2-2:
# INSTANCE_DOMAIN="ec2-instance2.devops-sam.rest"
# DOCKER_DOMAIN="ec2-docker2.devops-sam.rest"
# ==============================

# Update system
sudo apt update -y

# Install Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Install NGINX
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Run Docker container
sudo docker run -d \
  --restart always \
  -p 8080:8080 \
  hashicorp/http-echo \
  -listen=:8080 \
  -text="Namaste from Container"

# Create static page
sudo mkdir -p /var/www/instance
echo "<h1>Hello from Instance</h1>" | sudo tee /var/www/instance/index.html

# NGINX config
sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80;
    server_name ${INSTANCE_DOMAIN};

    root /var/www/instance;
    index index.html;
}

server {
    listen 80;
    server
