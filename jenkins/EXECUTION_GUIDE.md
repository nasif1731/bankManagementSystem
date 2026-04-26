# Task 1: Complete Execution Guide

This guide walks you through deploying and configuring Jenkins from start to finish.

## Phase 1: Pre-Deployment Preparation (10 minutes)

### 1.1 Verify Your Prerequisites

```powershell
# Check Terraform is installed
terraform version

# Check AWS CLI is installed and configured
aws sts get-caller-identity

# Verify you can access AWS resources
aws ec2 describe-vpcs --filters Name=tag:Name,Values=banking-vpc
```

**Expected Output**: 
- Terraform version >= 1.0
- AWS account ID shown
- VPC from Assignment 3 is found

### 1.2 Prepare Required Information

Gather the following before starting:

1. **Your Public IP Address**:
   ```powershell
   # Open this URL in browser or PowerShell
   (Invoke-WebRequest -Uri "https://ifconfig.me").Content
   # Or visit: https://ifconfig.me
   ```
   Save as: `203.0.113.42` (example, use your actual IP)

2. **AWS EC2 Key Pair**:
   - Open AWS Console → EC2 → Key Pairs
   - Create a new key pair named `jenkins-key` (or use existing)
   - Download the `.pem` file
   - Save to: `~\.ssh\jenkins-key.pem`
   - Set permissions: `icacls ~/.ssh/jenkins-key.pem /inheritance:r`

3. **GitHub Personal Access Token** (for later tasks):
   - Go to: GitHub → Settings → Developer Settings → Personal Access Tokens
   - Create new token with `repo` and `admin:repo_hook` scopes
   - Save the token (you'll need it in Step 5)

4. **AWS Access Key ID and Secret Key** (for Jenkins credentials):
   - Go to: AWS IAM → Users → Your User → Security Credentials
   - Create new Access Key
   - Save Access Key ID and Secret Access Key

### 1.3 Navigate to Jenkins Directory

```powershell
cd $HOME\Downloads\bankManagementSystem\jenkins
```

Verify all files exist:
```powershell
ls  # Should show: controller, agent, scripts, setup.md, plugins.txt, etc.
```

---

## Phase 2: Configure Terraform (5 minutes)

### 2.1 Update Controller Configuration with Your IP

```powershell
# Open the file
code controller\terraform.tfvars

# OR edit with PowerShell
notepad controller\terraform.tfvars
```

**Find this line**:
```terraform
my_ip = "0.0.0.0/32"
```

**Replace with your IP** (example):
```terraform
my_ip = "203.0.113.42/32"
```

**IMPORTANT**: Must be in CIDR format with `/32` at the end.

### 2.2 Verify Other Configuration

Check these values are correct:

```terraform
aws_region = "us-east-1"  # Match your Assignment 3 region
vpc_name = "banking-vpc"  # Match your VPC name
```

If different, update them to match your environment.

### 2.3 Save and Exit

Save the file. You're ready to deploy!

---

## Phase 3: Deploy Jenkins Controller (5-10 minutes)

### 3.1 Initialize Terraform

```powershell
cd controller

# Initialize Terraform (downloads AWS provider)
terraform init
```

**Expected Output**:
```
Terraform initialized in directory
```

### 3.2 Review the Plan

```powershell
# See what will be created
terraform plan
```

**Expected Output** shows it will create:
- 1 EC2 instance (controller)
- 1 Security group
- 1 IAM role
- 1 Elastic IP (optional)
- Other supporting resources

Review the plan. If it looks good, continue.

### 3.3 Deploy the Controller

```powershell
# Apply the configuration
terraform apply
```

**When prompted** (`Do you want to perform these actions?`):
- Type: `yes`
- Press: Enter

**This will take ~5 minutes**. You'll see:
```
aws_security_group.jenkins_controller: Creating...
aws_instance.jenkins_controller: Creating...
...
Apply complete!
```

### 3.4 Save the Controller Outputs

After apply completes, you'll see output values:

```
jenkins_url = "http://203.0.113.10:8080"
jenkins_controller_public_ip = "203.0.113.10"
ssh_command = "ssh -i jenkins-key.pem ec2-user@203.0.113.10"
```

**SAVE THESE VALUES** - you'll need them:
- Jenkins URL (note the IP address)
- SSH command
- Instance ID

---

## Phase 4: Deploy Jenkins Build Agent (5-10 minutes)

### 4.1 Navigate to Agent Directory

```powershell
cd ..\agent
```

### 4.2 Initialize Agent Terraform

```powershell
terraform init
```

### 4.3 Deploy Agent

```powershell
terraform plan
terraform apply
```

**When prompted**, type `yes`

This takes ~5 minutes. Save the outputs:
```
jenkins_agent_private_ip = "10.0.3.42"
jenkins_agent_work_dir = "/home/jenkins/agent"
jenkins_agent_label = "linux-agent"
```

---

## Phase 5: Wait for Jenkins to Start (5-10 minutes)

### 5.1 Check EC2 Instances

```powershell
# List running instances
aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`].[Tags[?Key==`Name`].Value|[0],InstanceId,PublicIpAddress]' --output table
```

You should see both:
- `jenkins-controller` (with public IP)
- `jenkins-build-agent` (in private subnet)

### 5.2 Check Jenkins Process

```powershell
# SSH to controller
ssh -i ~/.ssh/jenkins-key.pem ec2-user@<YOUR_CONTROLLER_IP>

# Check if Jenkins is running
sudo systemctl status jenkins

# View Jenkins logs
sudo tail -50 /var/log/jenkins/jenkins.log
```

**Look for messages like**:
```
Jenkins is running
Jenkins has fully started
```

**If not ready yet**: Wait a few minutes and check again. Jenkins takes 3-5 minutes to fully initialize.

### 5.3 Get Initial Admin Password

```powershell
# Still SSH'd into controller
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

**Save this password** - you'll need it immediately next to unlock Jenkins in the browser.

---

## Phase 6: Complete Jenkins Setup Wizard (20-30 minutes)

### 6.1 Open Jenkins UI

```powershell
# In your browser, open the Jenkins URL from Terraform output
# Example: http://203.0.113.10:8080
```

You should see the **Jenkins Unlock page**.

### 6.2 Unlock Jenkins

1. Copy the initial password from previous step
2. Paste into the **Administrator password** field
3. Click **Continue**

### 6.3 Install Suggested Plugins

You'll see two options:
- "Install suggested plugins" ← Click this
- "Select plugins to install"

**Click "Install suggested plugins"** and wait (5-10 minutes for downloads).

### 6.4 Create Admin User

After plugins install, create your admin account:

| Field | Value |
|-------|-------|
| Username | `admin` (or choose your own) |
| Password | Use strong password! |
| Full name | Your name |
| Email | your@email.com |

Click **Save and Finish**

### 6.5 Access Jenkins Dashboard

You're now logged into Jenkins! You should see the dashboard.

---

## Phase 7: Install Required Plugins (10-15 minutes)

### 7.1 Go to Plugin Manager

1. Click **Manage Jenkins** (left sidebar)
2. Click **Manage Plugins**
3. Click **Available plugins** tab

### 7.2 Search and Install Required Plugins

Search for and install these plugins **ONE BY ONE**:

1. **Pipeline** - for declarative pipelines
2. **Git** - for Git support
3. **GitHub Branch Source** - for GitHub integration
4. **Docker Pipeline** - for Docker support
5. **Credentials Binding** - for secure credentials
6. **Pipeline Utility Steps** - pipeline utilities
7. **SonarQube Scanner** - code quality scanning
8. **Blue Ocean** - modern UI

For each plugin:
1. Search in "Available plugins" tab
2. Check the checkbox
3. After selecting all, scroll down
4. Click **Download now and install after restart**
5. Check **Restart Jenkins when installation is complete**

Jenkins will restart automatically.

### 7.3 Wait for Restart

Jenkins will be offline for 1-2 minutes. Wait until you can log back in.

---

## Phase 8: Create Jenkins Credentials (15 minutes)

### 8.1 Navigate to Credentials

1. Click **Manage Jenkins**
2. Click **Manage Credentials**
3. Click **Global** (under "Stores")

### 8.2 Create AWS Credentials

1. Click **Add Credentials** (left sidebar)
2. **Kind**: `AWS Credentials`
3. Fill in:
   - **ID**: `aws-credentials`
   - **Description**: `AWS IAM credentials for Jenkins`
   - **Access Key ID**: (Your AWS access key)
   - **Secret Access Key**: (Your AWS secret key)
4. Click **Create**

### 8.3 Create GitHub PAT

1. Click **Add Credentials**
2. **Kind**: `Username with password`
3. Fill in:
   - **Username**: (Your GitHub username)
   - **Password**: (Your GitHub PAT)
   - **ID**: `github-pat`
   - **Description**: `GitHub Personal Access Token`
4. Click **Create**

### 8.4 Create SonarQube Token

1. Click **Add Credentials**
2. **Kind**: `Secret text`
3. Fill in:
   - **Secret**: (Your SonarQube token, or placeholder for now)
   - **ID**: `sonarqube-token`
   - **Description**: `SonarQube authentication token`
4. Click **Create**

### 8.5 Create Docker/ECR Credentials

1. Click **Add Credentials**
2. **Kind**: `Username with password`
3. Fill in:
   - **Username**: `AWS`
   - **Password**: (Your AWS secret key)
   - **ID**: `ecr-credentials`
   - **Description**: `AWS ECR credentials for Docker`
4. Click **Create**

### 8.6 Create Slack Webhook (Optional)

1. Click **Add Credentials**
2. **Kind**: `Secret text`
3. Fill in:
   - **Secret**: (Your Slack webhook URL, or skip for now)
   - **ID**: `slack-webhook`
   - **Description**: `Slack webhook URL`
4. Click **Create**

### 8.7 Verify Credentials

Go back to **Manage Credentials → Global**

You should see all credentials listed with IDs visible (values masked as ****).

---

## Phase 9: Configure GitHub Plugin (10 minutes)

### 9.1 Go to System Settings

1. Click **Manage Jenkins**
2. Click **System**

### 9.2 Configure GitHub

Scroll down to find **GitHub** section:

1. Click **Add GitHub Server**
2. Enter:
   - **GitHub Server**: `https://api.github.com`
   - **Credentials**: Select `github-pat` from dropdown
3. Click **Test Connection**

**Expected**: "Credentials verified for user: <your_github_username>"

4. Click **Save**

---

## Phase 10: Set Up Agent SSH Communication (15 minutes)

### 10.1 Generate SSH Key on Controller

```powershell
# SSH to controller
ssh -i ~/.ssh/jenkins-key.pem ec2-user@<CONTROLLER_IP>

# Switch to jenkins user
sudo su - jenkins

# Generate SSH key pair
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# Display the public key
cat ~/.ssh/id_rsa.pub
```

**Copy the entire output** (it's your public key)

### 10.2 Add Public Key to Agent

```powershell
# Get agent private IP from earlier Terraform output
# Example: 10.0.3.42

# In a new terminal, SSH to agent using Systems Manager Session Manager or bastion
# If you don't have direct access, use AWS Systems Manager

# Once on agent, become jenkins user
sudo su - jenkins

# Create .ssh directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add controller's public key
cat >> ~/.ssh/authorized_keys << 'EOF'
<PASTE_THE_PUBLIC_KEY_HERE>
EOF

# Set permissions
chmod 600 ~/.ssh/authorized_keys
```

### 10.3 Test SSH Connection from Controller

```powershell
# Still as jenkins user on controller
ssh -i ~/.ssh/id_rsa jenkins@<AGENT_PRIVATE_IP>

# Should successfully connect to agent
# If successful, type 'exit' to disconnect
```

---

## Phase 11: Add Agent in Jenkins UI (10 minutes)

### 11.1 Navigate to Nodes

1. Click **Manage Jenkins**
2. Click **Manage Nodes and Clouds**
3. Click **New Node**

### 11.2 Create Agent Node

1. **Node name**: `linux-agent`
2. **Type**: `Permanent Agent`
3. Click **Create**

### 11.3 Configure Agent

Fill in the following:

| Setting | Value |
|---------|-------|
| **Remote root directory** | `/home/jenkins/agent` |
| **Labels** | `linux-agent` |
| **Usage** | `Use this node as much as possible` |
| **Launch method** | `Launch agents via SSH` |
| **Host** | (Agent private IP, e.g., 10.0.3.42) |
| **Credentials** | Create new SSH credentials (see below) |
| **Host Key Verification** | `Non verifying Verification Strategy` |
| **Availability** | `Keep this agent online as much as possible` |

### 11.4 Add SSH Credentials for Agent Communication

When configuring agent, you need SSH credentials:

1. Click **Add** → **Jenkins** (next to Credentials field)
2. **Kind**: `SSH Username with private key`
3. Fill in:
   - **Username**: `jenkins`
   - **Private Key**: (Paste content of `/home/jenkins/.ssh/id_rsa` from controller)
   - **ID**: `jenkins-ssh-key`
   - **Description**: `SSH key for Jenkins to agent communication`
4. Click **Add**

### 11.5 Save Agent Configuration

1. Select the SSH credential from dropdown
2. Click **Save**
3. Wait for agent to connect (may take 1-2 minutes)

### 11.6 Verify Agent is Online

1. Go back to **Manage Nodes and Clouds**
2. Click on `linux-agent`
3. Should show: **Agent is connected and online** ✓

---

## Phase 12: Create and Test Sanity-Check Pipeline (10 minutes)

### 12.1 Create New Pipeline Job

1. Click **New Item** (Jenkins dashboard)
2. **Enter item name**: `sanity-check-pipeline`
3. **Select**: `Pipeline`
4. Click **OK**

### 12.2 Configure Pipeline

1. Go to **Pipeline** section
2. Select **Pipeline script** (not "Pipeline script from SCM")
3. Copy and paste the entire content from: `jenkins/Jenkinsfile.sanity-check`
4. Click **Save**

### 12.3 Run the Pipeline

1. Click **Build Now** (left sidebar)
2. Wait for build to complete (should take 2-3 minutes)
3. Click on the build number in **Build History**
4. Click **Console Output** to view logs

### 12.4 Verify Success

In the console output, you should see:

```
✓ Agent Hostname: (agent hostname)
✓ Current User: jenkins
✓ java -version → Java 17
✓ git --version → Git installed
✓ docker --version → Docker installed
✓ aws --version → AWS CLI installed
✓ terraform version → Terraform installed
✓ SUCCESS - Sanity Check Passed!
```

If you see SUCCESS at the end, Task 1 is working! ✅

---

## Phase 13: Take Screenshots for Submission (10 minutes)

### 13.1 Dashboard Screenshot

1. Go to Jenkins Dashboard
2. Take screenshot showing you're logged in as admin
3. Save as: `01-jenkins-dashboard.png`

### 13.2 Manage Nodes Screenshot

1. Go to **Manage Jenkins** → **Manage Nodes and Clouds**
2. Make sure agent shows **online** ✓
3. Take screenshot
4. Save as: `02-manage-nodes.png`

### 13.3 Credentials Screenshot

1. Go to **Manage Jenkins** → **Manage Credentials** → **Global**
2. Make sure all 5 credentials are visible with IDs shown
3. Values should be masked (*****)
4. Take screenshot
5. Save as: `03-credentials.png`

### 13.4 Plugins Screenshot

1. Go to **Manage Jenkins** → **Manage Plugins** → **Installed**
2. Search for and show the 8 required plugins:
   - Pipeline
   - Git
   - GitHub Branch Source
   - Docker Pipeline
   - Credentials Binding
   - Pipeline Utility Steps
   - SonarQube Scanner
   - Blue Ocean
3. Take screenshots (may need multiple if list is long)
4. Save as: `04-plugins-1.png`, `04-plugins-2.png`, etc.

### 13.5 Sanity-Check Pipeline Success Screenshot

1. Go to **sanity-check-pipeline** job
2. Click on the latest successful build
3. Click **Console Output**
4. Scroll to bottom to show SUCCESS message
5. Take screenshot
6. Save as: `05-pipeline-success.png`

---

## Troubleshooting Quick Reference

### Can't Access Jenkins UI
- Verify `my_ip` is correct in terraform.tfvars
- Check security group allows port 8080 from your IP
- Verify instance is running: `aws ec2 describe-instances`

### Jenkins Won't Start
```powershell
ssh -i ~/.ssh/jenkins-key.pem ec2-user@<IP>
sudo systemctl status jenkins
sudo tail -100 /var/log/jenkins/jenkins.log
```

### Agent Won't Connect
- Verify SSH keys are set up correctly
- Check agent node logs in Jenkins UI
- Verify agent security group allows port 22 from VPC

### Plugins Won't Install
- Check internet connectivity
- Check disk space: `df -h`
- Restart Jenkins and try again

---

## Summary Checklist

- [ ] Prerequisites verified (Terraform, AWS CLI, IP address)
- [ ] Terraform configured with your IP
- [ ] Controller deployed and running
- [ ] Agent deployed and running
- [ ] Jenkins UI accessible
- [ ] Setup wizard completed
- [ ] Required plugins installed
- [ ] 5 credentials created
- [ ] GitHub plugin configured
- [ ] SSH keys exchanged between controller and agent
- [ ] Agent added and showing as ONLINE
- [ ] Sanity-check pipeline created and SUCCEEDED
- [ ] 5+ screenshots taken
- [ ] Ready for submission!

---

## Next Steps

After completing Task 1:
1. Review SHARED_LIBRARY_REFERENCE.md for Task 2 preparation
2. Start planning Groovy shared library functions
3. Create jenkins/tasks/task2 folder structure
4. Begin Task 2: Groovy Shared Libraries

**Total Time**: ~2-3 hours for full setup

Good luck! 🚀
