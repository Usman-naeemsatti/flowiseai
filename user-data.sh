#!/bin/bash

sudo yum install docker -y
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo yum install git -y
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo git clone https://github.com/FlowiseAI/Flowise.git
sudo mv Flowise /home/ec2-user/
sudo rm -rf /home/ec2-user/Flowise/docker/docker-compose.yml
sudo cat > /home/ec2-user/Flowise/docker/docker-compose.yml << EOF
version: '3.1'

services:
    flowise:
        image: flowiseai/flowise
        restart: always
        environment:
            - PORT=${PORT}
            - DATABASE_TYPE=${DATABASE_TYPE}
            - DATABASE_PORT=${DATABASE_PORT}
            - DATABASE_HOST=${DATABASE_HOST}
            - DATABASE_NAME=${DATABASE_NAME}
            - DATABASE_USER=${DATABASE_USER}
            - DATABASE_PASSWORD=${DATABASE_PASSWORD}
        ports:
            - '${PORT}:${PORT}'
        volumes:
            - ~/.flowise:/root/.flowise
        command: /bin/sh -c "sleep 3; flowise start"
EOF

sudo docker-compose -f /home/ec2-user/Flowise/docker/docker-compose.yml up -d

