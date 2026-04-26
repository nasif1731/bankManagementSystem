# Jenkins Controller and Build Agent Setup Guide

This document provides step-by-step instructions for setting up the Jenkins infrastructure, including the controller and build agent, based on Terraform and Assignment 3 VPC.

## Prerequisites

- AWS Account with permissions to create EC2, security groups, and IAM roles
- Terraform installed locally (v1.0 or higher)
- AWS CLI configured with credentials
- An SSH key pair created in AWS (e.g., `jenkins-key`)
- Your IP address in CIDR notation (e.g., `203.0.113.42/32`)
- GitHub Personal Access Token (PAT) for cloning repositories
- AWS Access Key and Secret Key
- SonarQube token (for later tasks)
- Slack webhook URL (for notifications)

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                   AWS Region (us-east-1)                    │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           VPC: 10.0.0.0/16 (from Assignment 3)       │  │
│  │                                                        │  │
│  │  ┌─────────────────────────────────────────────────┐ │  │
│  │  │     Public Subnets (10.0.1.0/24, 10.0.2.0/24)   │ │  │
│  │  │                                                   │ │  │
│  │  │  ┌────────────────────────────────────────────┐ │ │  │
│  │  │  │   Jenkins Controller (t3.medium)           │ │ │  │
│  │  │  │   Port 8080: Your IP Only                  │ │ │  │
│  │  │  │   Port 22: Your IP Only                    │ │ │  │
│  │  │  │   IAM: Full Admin Access                   │ │ │  │
│  │  │  └────────────────────────────────────────────┘ │ │  │
│  │  └─────────────────────────────────────────────────┘ │  │
│  │                                                        │  │
│  │  ┌─────────────────────────────────────────────────┐ │  │
│  │  │    Private Subnets (10.0.3.0/24, 10.0.4.0/24)   │ │  │
│  │  │                                                   │ │  │
│  │  │  ┌────────────────────────────────────────────┐ │ │  │
│  │  │  │   Jenkins Build Agent (t3.medium)         │ │ │  │
│  │  │  │   SSH from VPC: Enabled                    │ │ │  │
│  │  │  │   Connected to Controller via SSH JNLP    │ │ │  │
│  │  │  │   Label: linux-agent                       │ │ │  │
│  │  │  │   Workdir: /home/jenkins/agent            │ │ │  │
│  │  │  └────────────────────────────────────────────┘ │ │  │
│  │  └─────────────────────────────────────────────────┘ │  │
│  │                                                        │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Step 1: Update Jenkins Controller Terraform Configuration

Before deploying, update the controller configuration with your IP:

### File: `jenkins/controller/terraform.tfvars`

1. Open `jenkins/controller/terraform.tfvars`
2. Update the `my_ip` variable with your IP address in CIDR notation:
   ```terraform
   my_ip = "203.0.113.42/32"  # Replace with your actual IP
   ```
3. Verify the AWS region matches where Assignment 3 VPC exists
4. Adjust `instance_type` if needed (default: `t3.medium` is recommended)

## Step 2: Deploy Jenkins Controller with Terraform

### 2a: Navigate to Controller Directory
```bash
cd jenkins/controller
```

### 2b: Initialize Terraform
```bash
terraform init
```

This will:
- Download AWS provider
- Initialize the Terraform working directory

### 2c: Review the Plan
```bash
terraform plan
```

This will show you all resources to be created. Review carefully:
- EC2 instance in public subnet
- Security group with restricted access
- IAM role with admin permissions
- Elastic IP assignment
- CloudWatch log group

### 2d: Apply the Configuration
```bash
terraform apply
```

When prompted, type `yes` to proceed.

### 2e: Capture Outputs
After successful apply, Terraform will output important values:
```
jenkins_url = "http://203.0.113.10:8080"
jenkins_controller_instance_id = "i-0123456789abcdef"
ssh_command = "ssh -i jenkins-key.pem ec2-user@203.0.113.10"
```

**Save these outputs** - you'll need them for the next steps.

## Step 3: Wait for Jenkins to Start

The controller EC2 instance will take **5-10 minutes** to fully initialize:

1. EC2 instance boots up
2. user_data script executes
3. Java 17 is installed
4. Jenkins LTS is installed and started

### 3a: Monitor the Startup
You can SSH into the controller and view the startup logs:

```bash
ssh -i jenkins-key.pem ec2-user@<jenkins_public_ip>

# View Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Check if Jenkins process is running
ps aux | grep jenkins

# View initial admin password (after Jenkins starts)
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 3b: Wait for Ready State
Look for log lines like:
```
Jenkins is running
INFO	h.m.DownloadService$Downloadable	#downloadable-list is up to date (current is v13b_6f980eca0ea7ebf3e1caa0872ea)
```

## Step 4: Deploy Jenkins Build Agent with Terraform

### 4a: Navigate to Agent Directory
```bash
cd ../agent
```

### 4b: Initialize Terraform
```bash
terraform init
```

### 4c: Review the Plan
```bash
terraform plan
```

Verify:
- EC2 instance in private subnet
- Security group with SSH access from VPC
- IAM role with admin permissions
- agent label: `linux-agent`

### 4d: Apply the Configuration
```bash
terraform apply
```

### 4e: Capture Agent Outputs
Save these important values:
```
jenkins_agent_instance_id = "i-abcdef1234567890"
jenkins_agent_private_ip = "10.0.3.42"
jenkins_agent_work_dir = "/home/jenkins/agent"
```

## Step 5: Configure SSH Communication Between Controller and Agent

### 5a: Generate SSH Key for Jenkins User (On Controller)

```bash
# SSH into controller
ssh -i jenkins-key.pem ec2-user@<controller_public_ip>

# Switch to Jenkins user
sudo su - jenkins

# Create SSH key pair for jenkins user
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# Display the public key (you'll need this for next step)
cat ~/.ssh/id_rsa.pub

# Exit jenkins user
exit
```

### 5b: Add Controller's Public Key to Agent

```bash
# From your local machine, SSH into the agent (via bastion or Systems Manager Session Manager)
# Option 1: Use Systems Manager Session Manager (requires IAM permissions)
# Option 2: SSH via a jump host if available

# Once on the agent instance:
sudo su - jenkins

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add the controller's public key to authorized_keys
cat >> ~/.ssh/authorized_keys << 'EOF'
<paste_controller_public_key_here>
EOF

# Set proper permissions
chmod 600 ~/.ssh/authorized_keys

# Verify connectivity from controller
exit
```

### 5c: Test SSH Connection

From the controller:
```bash
sudo su - jenkins

# Try to SSH to the agent
ssh -i ~/.ssh/id_rsa jenkins@<agent_private_ip>

# If successful, you should be on the agent
hostname

# Exit
exit
```

## Step 6: Access Jenkins UI and Complete Setup Wizard

### 6a: Open Jenkins in Web Browser
1. Open `http://<controller_public_ip>:8080` in your browser
2. You should see the Jenkins unlock page

### 6b: Retrieve Initial Admin Password

```bash
# From your local machine, SSH to controller
ssh -i jenkins-key.pem ec2-user@<controller_public_ip>

# Get the initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 6c: Complete the Setup Wizard

1. **Unlock Jenkins**: Paste the initial password
2. **Install Plugins**: Choose "Install suggested plugins" when prompted
3. **Create First Admin User**:
   - Username: `admin`
   - Password: `<strong_password>` (something secure)
   - Full Name: `Jenkins Administrator`
   - Email: `admin@example.com`
4. **Jenkins URL**: Keep default or update to your elastic IP if assigned
5. **Start Using Jenkins**: Click to proceed

### 6d: Install Required Plugins

After setup wizard completes:

1. Go to **Manage Jenkins** → **Manage Plugins**
2. Go to **Available plugins** tab
3. Search for and install each of these plugins:
   - `Pipeline` (Pipeline/Groovy support)
   - `Git` (Git integration)
   - `GitHub Branch Source` (GitHub integration)
   - `Docker Pipeline` (Docker support)
   - `Credentials Binding` (Secure credential binding)
   - `Pipeline Utility Steps` (Pipeline utilities)
   - `SonarQube Scanner` (Code quality)
   - `Blue Ocean` (Modern UI)

4. After installing plugins, restart Jenkins:
   - Go to **Manage Jenkins** → **System**
   - Or restart via SSH: `sudo systemctl restart jenkins`

## Step 7: Create Jenkins Credentials

### 7a: Navigate to Credentials Page
1. Go to **Manage Jenkins** → **Manage Credentials**
2. Click on **Global** (or create a new domain)

### 7b: Create AWS Credentials

1. Click **Add Credentials**
2. Select **Kind**: `AWS Credentials`
3. Enter:
   - **Scope**: `Global`
   - **ID**: `aws-credentials`
   - **Description**: `AWS IAM credentials for Jenkins`
   - **Access Key ID**: `<your_aws_access_key>`
   - **Secret Access Key**: `<your_aws_secret_key>`
4. Click **Create**

### 7c: Create GitHub PAT Credential

1. Click **Add Credentials**
2. Select **Kind**: `Username with password`
3. Enter:
   - **Scope**: `Global`
   - **Username**: `<your_github_username>`
   - **Password**: `<your_github_pat>`
   - **ID**: `github-pat`
   - **Description**: `GitHub Personal Access Token`
4. Click **Create**

### 7d: Create SonarQube Token (for Task 4)

1. Click **Add Credentials**
2. Select **Kind**: `Secret text`
3. Enter:
   - **Scope**: `Global`
   - **Secret**: `<your_sonarqube_token>`
   - **ID**: `sonarqube-token`
   - **Description**: `SonarQube authentication token`
4. Click **Create**

### 7e: Create Docker/ECR Credentials

1. Click **Add Credentials**
2. Select **Kind**: `Username with password`
3. Enter:
   - **Scope**: `Global`
   - **Username**: `AWS`
   - **Password**: `<your_aws_secret_key>`
   - **ID**: `ecr-credentials`
   - **Description**: `AWS ECR credentials for Docker`
4. Click **Create**

### 7f: Create Slack Webhook (Optional)

1. Click **Add Credentials**
2. Select **Kind**: `Secret text`
3. Enter:
   - **Scope**: `Global`
   - **Secret**: `<your_slack_webhook_url>`
   - **ID**: `slack-webhook`
   - **Description**: `Slack webhook URL`
4. Click **Create**

## Step 8: Configure GitHub Plugin

### 8a: Go to GitHub Plugin Settings
1. Go to **Manage Jenkins** → **System**
2. Find section **GitHub**
3. Click **Add GitHub Server**

### 8b: Configure GitHub Connection
1. **GitHub Server**: `https://api.github.com`
2. **Credentials**: Select `github-pat` (created in Step 7c)
3. **Manage hooks**: Check this box
4. Click **Test Connection** - you should see:
   ```
   Credentials verified for user: <your_github_username>
   ```
5. Click **Save**

## Step 9: Configure Build Agent in Jenkins

### 9a: Navigate to Nodes
1. Go to **Manage Jenkins** → **Manage Nodes and Clouds**
2. Click **New Node**

### 9b: Create Agent Node

1. **Node name**: `linux-agent`
2. **Type**: Select `Permanent Agent`
3. Click **Create**

### 9c: Configure Agent Settings

Enter the following configuration:

- **Description**: `Linux build agent in private subnet`
- **Number of executors**: `4` (adjust based on instance type)
- **Remote root directory**: `/home/jenkins/agent`
- **Labels**: `linux-agent`
- **Usage**: `Use this node as much as possible`
- **Launch method**: `Launch agents via SSH`
  - **Host**: `<agent_private_ip>` (e.g., `10.0.3.42`)
  - **Credentials**: Create SSH credentials:
    - Click **Add** → **Jenkins**
    - **Kind**: `SSH Username with private key`
    - **Username**: `jenkins`
    - **Private Key**: Paste the content of `/home/jenkins/.ssh/id_rsa` from the controller
    - **ID**: `jenkins-ssh-key`
    - **Description**: `SSH key for Jenkins to agent communication`
  - **Host Key Verification Strategy**: `Non verifying Verification Strategy`
- **Availability**: `Keep this agent online as much as possible`

### 9d: Save the Agent Configuration

1. Click **Save**
2. Wait for the agent to connect (may take a minute)
3. You should see **Agent is connected and online** message

### 9e: Verify Agent Connection

1. Go to **Manage Jenkins** → **Manage Nodes**
2. You should see `linux-agent` listed and marked as **online**
3. Click on the agent name to view details and logs

## Step 10: Create a Sanity-Check Pipeline Job

### 10a: Create a New Pipeline Job

1. Click **New Item**
2. **Enter item name**: `sanity-check-pipeline`
3. **Select**: `Pipeline`
4. Click **OK**

### 10b: Configure the Pipeline

1. Go to **Pipeline** section
2. Select **Pipeline script** (not from SCM)
3. Paste the following pipeline code:

```groovy
pipeline {
    agent {
        label 'linux-agent'
    }
    
    stages {
        stage('Verify Agent') {
            steps {
                echo "=== Agent Verification ==="
                sh 'hostname'
                sh 'whoami'
                sh 'pwd'
            }
        }
        
        stage('Verify Tools') {
            steps {
                echo "=== Tool Verification ==="
                sh 'java -version'
                sh 'git --version'
                sh 'docker --version'
                sh 'aws --version'
                sh 'terraform version'
            }
        }
        
        stage('Hello from Agent') {
            steps {
                echo "=== Hello from Build Agent ==="
                sh 'echo "Hello from jenkins build agent on ${NODE_NAME}"'
            }
        }
    }
    
    post {
        always {
            echo "Pipeline execution completed on ${NODE_NAME}"
        }
        success {
            echo "SUCCESS: Sanity check passed!"
        }
        failure {
            echo "FAILURE: Sanity check failed!"
        }
    }
}
```

### 10c: Save and Run the Pipeline

1. Click **Save**
2. Click **Build Now**
3. Monitor the build in **Build History**
4. Click on the build number to see console output

### 10d: Verify Success

In the console output, you should see:
- Agent hostname
- Current user (jenkins)
- Current directory (/home/jenkins/agent)
- All tool versions (Java, Git, Docker, AWS CLI, Terraform)
- "Hello from jenkins build agent" message
- SUCCESS message at the end

## Troubleshooting Guide

### Jenkins Won't Start
```bash
# SSH to controller
ssh -i jenkins-key.pem ec2-user@<controller_ip>

# Check Jenkins logs
sudo tail -100 /var/log/jenkins/jenkins.log

# Try to manually start Jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
```

### Agent Can't Connect via SSH
```bash
# From controller, test SSH to agent
sudo su - jenkins
ssh -v jenkins@<agent_private_ip>

# Check SSH key permissions
chmod 600 ~/.ssh/id_rsa
chmod 700 ~/.ssh

# Verify agent SSH is configured
sudo systemctl status sshd
```

### Plugins Not Installing
- Increase Jenkins startup time (plugins download may be slow)
- Check internet connectivity from Jenkins instance
- Verify Jenkins user has sufficient disk space: `df -h`

### Credentials Not Working
- Verify credentials are in **Global** domain
- Check credential IDs match exactly in pipeline/jobs
- Test credentials by clicking **Test** button after entering them

### Pipeline Job Runs on Controller Instead of Agent
- Verify agent label is correct: `linux-agent`
- Ensure `agent { label 'linux-agent' }` is in pipeline
- Check agent is online in **Manage Nodes** page

## Next Steps

After completing this setup:
1. Create Groovy shared libraries (Task 2)
2. Set up SonarQube integration (Task 3)
3. Configure Docker ECR integration (Task 3)
4. Implement Blue-Green deployment (Task 4)
5. Set up monitoring with Prometheus and Grafana (Task 5)

## Files Reference

- `controller/main.tf` - Jenkins controller infrastructure
- `controller/variables.tf` - Configuration variables
- `controller/terraform.tfvars` - Variable values
- `agent/main.tf` - Build agent infrastructure
- `agent/variables.tf` - Configuration variables
- `agent/terraform.tfvars` - Variable values
- `scripts/jenkins-controller-init.sh` - Controller startup script
- `scripts/jenkins-agent-init.sh` - Agent startup script
- `plugins.txt` - List of installed plugins (to be captured from Jenkins UI)

## Security Notes

1. **Never commit credentials** to version control
2. **Restrict SSH access** by IP address (currently set to your IP only)
3. **Use strong passwords** for Jenkins admin account
4. **Rotate credentials** regularly
5. **Enable audit logging** in Jenkins for compliance
6. **Keep Jenkins and plugins updated**
7. **Run security scans** on agent EC2 instances

## Cleanup

To destroy all resources created by Terraform:

```bash
# From controller directory
cd jenkins/controller
terraform destroy

# From agent directory
cd ../agent
terraform destroy
```

**Warning**: This will terminate EC2 instances and delete all Jenkins data. Only run if you want to completely clean up.
