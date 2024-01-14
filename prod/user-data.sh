#!/bin/bash

mkdir -p /var/lib/jenkins
# install default-jre (needed for ubuntu 18.04)
apt-get update
apt-get install -y default-jre wget

# install jenkins and docker
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update
apt-get install -y jenkins unzip docker.io npm

# enable docker and add perms
usermod -G docker jenkins
systemctl enable docker
service docker start
service jenkins restart

# install awscli
curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install
aws --version
