#!/bin/bash

sudo yum install docker -y
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo yum install git -y
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
git clone https://github.com/langfuse/langfuse.git
sudo mv langfuse /home/ec2-user/
sudo rm -rf /home/ec2-user/langfuse/docker-compose.yml
sudo cat > /home/ec2-user/langfuse/docker-compose.yml << EOF
version: "3.5"

services:
  langfuse-server:
    image: ghcr.io/langfuse/langfuse:latest
    ports:
      - "80:${PORT}"
    environment:
      - DATABASE_HOST=${db_host}
      - DATABASE_USERNAME=${db_user}
      - DATABASE_PASSWORD=${db_pass}
      - DATABASE_NAME=${db_name}
      - NEXTAUTH_SECRET=mysecret
      - SALT=mysalt
      - NEXTAUTH_URL=http://localhost:${PORT}
EOF

sudo docker-compose -f /home/ec2-user/langfuse/docker-compose.yml up -d
