#!/bin/bash
# Jenkins Build Agent Initialization Script
# Installs dependencies and configures the agent for SSH communication with Jenkins controller

set -e

echo "=== Starting Jenkins Build Agent Setup ==="

# Update system packages
echo "Step 1: Updating system packages..."
yum update -y

 # Install Java 17
echo "Step 2: Installing Java 17..."
yum install -y java-17-amazon-corretto-devel
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
echo "JAVA_HOME=$JAVA_HOME" >> /etc/profile.d/java.sh

# Install Git
echo "Step 3: Installing Git..."
yum install -y git

# Install Docker
echo "Step 4: Installing Docker..."
amazon-linux-extras install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install AWS CLI v2
echo "Step 5: Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws

# Install Terraform
echo "Step 6: Installing Terraform..."
TERRAFORM_VERSION="1.6.4"
wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
mv terraform /usr/local/bin/
rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
terraform version

# Create jenkins user if it doesn't exist
echo "Step 7: Setting up jenkins agent user..."
if ! id "jenkins" &>/dev/null; then
    useradd -m -s /bin/bash jenkins
fi

# Set up SSH directory for Jenkins user
echo "Step 8: Configuring SSH for Jenkins..."
mkdir -p /home/jenkins/.ssh
chmod 700 /home/jenkins/.ssh
chown jenkins:jenkins /home/jenkins/.ssh

# Enable password-less sudo for jenkins user (for Docker commands, etc)
echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Add jenkins to docker group
usermod -a -G docker jenkins

# Create JENKINS_AGENT_WORKDIR
echo "Step 9: Creating Jenkins agent work directory..."
mkdir -p /home/jenkins/agent
chmod -R 755 /home/jenkins/agent
chown -R jenkins:jenkins /home/jenkins/agent

echo "=== Jenkins Build Agent Setup Complete ==="
echo "Agent is ready to receive SSH connections from Jenkins controller"
echo "Make sure to:"
echo "1. Add the controller's public SSH key to /home/jenkins/.ssh/authorized_keys"
echo "2. Configure the agent in Jenkins UI with label 'linux-agent'"
echo "3. Set remote work directory to: /home/jenkins/agent"
