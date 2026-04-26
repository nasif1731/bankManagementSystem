#!/bin/bash
# Jenkins Controller Initialization Script - Version 2 (Improved)
# More robust with better error handling and verification

set -e

exec > >(tee /var/log/jenkins-setup.log)
exec 2>&1

echo "========== Starting Jenkins Controller Setup (v2) =========="
echo "Start time: $(date)"

# ===== STEP 1: System Update =====
echo ""
echo "Step 1: Updating system packages..."
yum update -y 2>&1 | head -20
echo "✓ System updated"

# ===== STEP 2: Install Java 17 =====
echo ""
echo "Step 2: Installing Java 17..."
yum install -y java-17-amazon-corretto-devel 2>&1 | grep -i "installed\|complete\|error" || true

# Verify Java installed
JAVA_PATH=$(which java)
if [ -z "$JAVA_PATH" ]; then
    echo "❌ Java installation failed!"
    exit 1
fi

java -version
export JAVA_HOME=$(dirname $(dirname $JAVA_PATH))
echo "✓ Java installed at $JAVA_HOME"

# ===== STEP 3: Install Git =====
echo ""
echo "Step 3: Installing Git..."
yum install -y git 2>&1 | grep -i "installed\|complete\|error" || true
git --version
echo "✓ Git installed"

# ===== STEP 4: Install Docker =====
echo ""
echo "Step 4: Installing Docker..."
yum install -y docker 2>&1 | grep -i "installed\|complete\|error" || true
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
docker --version
echo "✓ Docker installed and running"

# ===== STEP 5: Install AWS CLI v2 =====
echo ""
echo "Step 5: Installing AWS CLI v2..."
cd /tmp
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install 2>&1 | tail -3
aws --version
echo "✓ AWS CLI installed"

# ===== STEP 6: Install Terraform =====
echo ""
echo "Step 6: Installing Terraform..."
TERRAFORM_VERSION="1.6.4"
cd /tmp
wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip -q "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
mv terraform /usr/local/bin/
terraform version
echo "✓ Terraform installed"

# ===== STEP 7: Install Jenkins =====
echo ""
echo "Step 7: Installing Jenkins LTS..."
wget -q -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install -y jenkins-2.541.3-1.noarch 2>&1 | grep -i "installed\|complete\|error" || true
echo "✓ Jenkins installed"

# ===== STEP 8: Create Jenkins user and configure =====
echo ""
echo "Step 8: Configuring Jenkins user..."
mkdir -p /var/lib/jenkins
chown -R jenkins:jenkins /var/lib/jenkins
usermod -a -G docker jenkins
echo "✓ Jenkins user configured"

# ===== STEP 9: Start Jenkins =====
echo ""
echo "Step 9: Starting Jenkins service..."
systemctl daemon-reload
systemctl start jenkins
sleep 5

# Verify Jenkins is running
if ! systemctl is-active --quiet jenkins; then
    echo "❌ Jenkins failed to start!"
    systemctl status jenkins
    journalctl -xe | tail -50
    exit 1
fi

systemctl status jenkins | grep -i "active\|running"
echo "✓ Jenkins started successfully"

# ===== STEP 10: Enable Jenkins on boot =====
echo ""
echo "Step 10: Enabling Jenkins on boot..."
systemctl enable jenkins
echo "✓ Jenkins enabled for auto-start"

# ===== STEP 11: Wait for Jenkins to initialize =====
echo ""
echo "Step 11: Waiting for Jenkins to initialize (60 seconds)..."
sleep 60

# ===== STEP 12: Get and display initial password =====
echo ""
echo "Step 12: Jenkins initialization complete!"
echo ""
echo "========== JENKINS INITIAL SETUP INFO =========="
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    INITIAL_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
    echo "✓ Jenkins Initial Admin Password:"
    echo "  $INITIAL_PASSWORD"
    echo ""
    echo "Access Jenkins at:"
    echo "  http://JENKINS_PUBLIC_IP:8080"
else
    echo "⚠ Password file not yet available"
    echo "Run: cat /var/lib/jenkins/secrets/initialAdminPassword"
fi

echo ""
echo "========== SETUP COMPLETE =========="
echo "Finish time: $(date)"
echo "See /var/log/jenkins-setup.log for full logs"
