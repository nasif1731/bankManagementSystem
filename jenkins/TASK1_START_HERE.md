# TASK 1: COMPLETE EXECUTION GUIDE
## Jenkins Installation and Basic Configuration

**Status**: Ready for deployment  
**Estimated Time**: 2-3 hours  
**Difficulty**: Easy-Medium

---

## 🎯 WHAT YOU'LL ACCOMPLISH

By end of this guide, you will have:

✅ EC2 instance running Jenkins controller in public subnet  
✅ EC2 instance running build agent in private subnet  
✅ Jenkins UI accessible at http://your-ip:8080  
✅ All required plugins installed  
✅ 5 credentials configured (AWS, GitHub, SonarQube, Docker, Slack)  
✅ Build agent connected and labeled "linux-agent"  
✅ Sanity-check pipeline running successfully  
✅ All required screenshots captured  

---

## PHASE 1: PRE-DEPLOYMENT VERIFICATION (10 minutes)

### Step 1.1: Find Your Public IP Address

```powershell
# Windows PowerShell - Get your public IP
Invoke-WebRequest -Uri "https://ifconfig.me" | Select-Object -ExpandProperty Content
```

**Example output**: `203.0.113.45`

💾 **Save this value**: You'll need it in Step 1.4

---

### Step 1.2: Verify AWS Credentials

```powershell
# Check AWS CLI is installed and credentials configured
aws sts get-caller-identity
```

**Expected output**:
```json
{
    "UserId": "AIDAI...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-user"
}
```

❌ **If error**: Configure AWS CLI first
```powershell
aws configure
# Enter: Access Key ID
# Enter: Secret Access Key
# Enter: Region (us-east-1)
# Enter: Output format (json)
```

---

### Step 1.3: Verify VPC from Assignment 3 Exists

```powershell
# Check VPC with tag Name=task1-vpc (from your Assignment 3 Task 1)
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=task1-vpc" --region us-east-1
```

**Expected output**: Should show VPC with CIDR `10.0.0.0/16`

✅ **Your VPC name**: `task1-vpc`  
✅ **Your VPC CIDR**: `10.0.0.0/16`  
✅ **Public subnets**: `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24`  
✅ **Private subnets**: `10.0.10.0/24`, `10.0.11.0/24`

---

### Step 1.4: Verify EC2 Key Pair Exists

```powershell
# List available EC2 key pairs
aws ec2 describe-key-pairs --region us-east-1
```

**Expected output**: Should show at least one key pair

💾 **Note the key pair name**: You'll use this to SSH to instances

---

## PHASE 2: TERRAFORM DEPLOYMENT (20 minutes)

### Step 2.1: Update Controller Configuration

**File**: `jenkins/controller/terraform.tfvars`

1. Open file in VS Code:
```powershell
code jenkins/controller/terraform.tfvars
```

2. Find this line:
```hcl
my_ip = "0.0.0.0/32"
```

3. Replace with your actual IP (from Step 1.1):
```hcl
my_ip = "203.0.113.45/32"
```

⚠️ **IMPORTANT**: Add `/32` at the end (means only your single IP)

4. Save file (`Ctrl+S`)

---

### Step 2.2: Deploy Jenkins Controller

```powershell
# Navigate to controller directory
cd jenkins/controller

# Initialize Terraform
terraform init

# Review changes
terraform plan

# Deploy infrastructure
terraform apply

# Confirm by typing: yes
```

⏳ **Wait 2-3 minutes** while Terraform creates resources

**Expected output** (at end):
```
Apply complete! Resources added: 5, changed: 0, destroyed: 0

Outputs:
jenkins_controller_instance_id = "i-0123456789abcdef0"
jenkins_controller_public_ip = "203.0.113.100"
jenkins_url = "http://203.0.113.100:8080"
ssh_command = "ssh -i ~/.ssh/your-key.pem ec2-user@203.0.113.100"
```

💾 **Save these outputs**: You'll need them throughout this guide

---

### Step 2.3: Deploy Jenkins Agent

```powershell
# Navigate to agent directory
cd ../agent

# Initialize Terraform
terraform init

# Review changes
terraform plan

# Deploy infrastructure
terraform apply

# Confirm by typing: yes
```

⏳ **Wait 2-3 minutes** while Terraform creates resources

**Expected output** (at end):
```
Apply complete! Resources added: 4, changed: 0, destroyed: 0

Outputs:
jenkins_agent_private_ip = "10.0.2.50"
jenkins_agent_instance_id = "i-9876543210fedcba0"
ssh_command = "ssh -i ~/.ssh/your-key.pem ec2-user@10.0.2.50"
```

💾 **Save agent private IP**: You'll need it in Step 4.2

---

### Step 2.4: Verify Instances Are Running

```powershell
# Check EC2 instances
aws ec2 describe-instances --filters "Name=tag:Environment,Values=jenkins" --region us-east-1 --query 'Reservations[].Instances[].[InstanceId,State.Name,PrivateIpAddress,PublicIpAddress]' --output table
```

**Expected output**:
```
|  InstanceId             | State | PrivateIP    | PublicIP        |
|  i-0123456789abcdef0    | running | 10.0.1.50  | 203.0.113.100   |
|  i-9876543210fedcba0    | running | 10.0.2.50  | None            |
```

✅ Both should be **running**  
✅ Controller should have **PublicIP**  
✅ Agent should have **No PublicIP** (private subnet)

---

### Step 2.5: Wait for Jenkins to Initialize

⏳ **Jenkins takes 3-5 minutes to start** after EC2 boots

```powershell
# Check if Jenkins is ready (repeat every 30 seconds)
$controller_ip = "203.0.113.100"  # Replace with your IP
curl -s -o /dev/null -w "%{http_code}" "http://${controller_ip}:8080/login"
```

When you see **`200`**, Jenkins is ready!

---

## PHASE 3: JENKINS UI INITIAL SETUP (30 minutes)

### Step 3.1: Access Jenkins

1. Open browser
2. Go to: `http://203.0.113.100:8080` (use YOUR IP from Step 2.2)
3. You should see **"Unlock Jenkins"** page

---

### Step 3.2: Get Initial Admin Password

```powershell
# SSH to controller instance
ssh -i ~/.ssh/your-key.pem ec2-user@203.0.113.100

# Once logged in (you'll see ec2-user@ip prompt):
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

📋 **Copy the entire password string** (it's a long alphanumeric code)

---

### Step 3.3: Unlock Jenkins

1. Back in browser at Jenkins unlock page
2. Paste the password from Step 3.2
3. Click **"Continue"**

---

### Step 3.4: Install Suggested Plugins

1. You'll see **"Getting Started"** page with two options:
2. Click **"Install suggested plugins"**

⏳ **Wait 5-10 minutes** while plugins install

---

### Step 3.5: Create First Admin User

After plugins finish installing, you'll see **"Create First Admin User"** form:

Fill in:
- **Username**: `admin` (or your preferred name)
- **Password**: Create a strong password (must be different from initial password!)
- **Full name**: Your full name
- **Email**: Your email address

⚠️ **DO NOT** keep the default initial password - create a new one!

Click **"Save and Continue"**

---

### Step 3.6: Confirm Jenkins URL

You'll see **"Instance Configuration"** with Jenkins URL:
- Should show: `http://203.0.113.100:8080/`
- Click **"Save and Finish"**

---

### Step 3.7: See Jenkins Dashboard

✅ You should now see the **Jenkins Dashboard**

📸 **SCREENSHOT #1**: Take screenshot of dashboard
- Show URL bar, navigation menu, "New Item" button

---

## PHASE 4: INSTALL REQUIRED PLUGINS (15 minutes)

### Step 4.1: Go to Plugin Manager

1. Click **"Manage Jenkins"** (left sidebar)
2. Click **"Manage Plugins"**
3. Click **"Available plugins"** tab

---

### Step 4.2: Search and Install Each Required Plugin

These 8 are **required** by the assignment:

| Plugin Name | Search For | What to do |
|---|---|---|
| Pipeline | `Pipeline` | Check box, scroll down, click Install |
| Git | `Git` | Check box, scroll down, click Install |
| GitHub Branch Source | `GitHub Branch Source` | Check box |
| Docker Pipeline | `Docker Pipeline` | Check box |
| Credentials Binding | `Credentials Binding` | Check box |
| Pipeline Utility Steps | `Pipeline Utility Steps` | Check box |
| SonarQube Scanner | `SonarQube Scanner` | Check box |
| Blue Ocean | `Blue Ocean` | Check box |

**Then click**: **"Install without restart"**

⏳ **Wait 5-10 minutes** for installation

### Step 4.3: Verify Required Plugins

1. Go back to **"Manage Jenkins"** > **"Manage Plugins"**
2. Click **"Installed plugins"** tab
3. Search for each plugin name - they should all be there ✅

📸 **SCREENSHOT #2**: Manage Plugins page
- Show at least the 8 required plugins in installed list

---

## PHASE 5: CREATE JENKINS CREDENTIALS (15 minutes)

### Step 5.1: Go to Credentials Page

1. Click **"Manage Jenkins"** (left sidebar)
2. Click **"Manage Credentials"**
3. Click **"(global)"** under Store
4. Click **"Add Credentials"** (left sidebar)

---

### Step 5.2: Create AWS Credentials

1. **Kind**: Select **"AWS Credentials"**
2. **Scope**: Keep as **"Global"**
3. **Access Key ID**: Paste your AWS access key
4. **Secret Access Key**: Paste your AWS secret key
5. **ID**: `aws-credentials` ← **Use exactly this ID**
6. **Description**: `AWS Access Keys for ECR and deployment`
7. Click **"Create"**

---

### Step 5.3: Create GitHub Personal Access Token Credential

First, create token on GitHub:
- Go to GitHub.com
- Click your profile icon > Settings
- Developer settings > Personal access tokens > Tokens (classic)
- Click "Generate new token (classic)"
- **Scopes to enable**:
  - ✅ `repo` (full control of private repositories)
  - ✅ `admin:repo_hook` (write access to hooks)
- Click "Generate token"
- 📋 **Copy the token** (you won't see it again!)

Back in Jenkins:
1. Click **"Add Credentials"** again
2. **Kind**: Select **"Username with password"**
3. **Username**: `github` (or your GitHub username)
4. **Password**: Paste the GitHub token you just created
5. **ID**: `github-pat` ← **Use exactly this ID**
6. **Description**: `GitHub Personal Access Token`
7. Click **"Create"**

---

### Step 5.4: Create SonarQube Token Credential (Placeholder)

For now, we'll create a placeholder (Task 3 will update this):

1. Click **"Add Credentials"** again
2. **Kind**: Select **"Secret text"**
3. **Secret**: `placeholder-sonarqube-token`
4. **ID**: `sonarqube-token` ← **Use exactly this ID**
5. **Description**: `SonarQube API Token (update in Task 3)`
6. Click **"Create"**

---

### Step 5.5: Create Docker/ECR Credentials

1. Click **"Add Credentials"** again
2. **Kind**: Select **"Username with password"**
3. **Username**: `AWS` (literal word)
4. **Password**: Paste your AWS secret access key
5. **ID**: `ecr-credentials` ← **Use exactly this ID**
6. **Description**: `AWS ECR Credentials for Docker`
7. Click **"Create"**

---

### Step 5.6: Create Slack Webhook Credential

First, get Slack webhook:
- Go to https://api.slack.com/apps
- Create New App or select existing
- Go to "Incoming Webhooks"
- Click "Add New Webhook to Workspace"
- Select channel and authorize
- 📋 **Copy the Webhook URL**

Back in Jenkins:
1. Click **"Add Credentials"** again
2. **Kind**: Select **"Secret text"**
3. **Secret**: Paste the Slack webhook URL
4. **ID**: `slack-webhook` ← **Use exactly this ID**
5. **Description**: `Slack Webhook for Notifications`
6. Click **"Create"**

---

### Step 5.7: Verify All Credentials

1. Go to **"Manage Jenkins"** > **"Manage Credentials"**
2. Click **"(global)"** under Store
3. You should see 5 credentials:
   - ✅ `aws-credentials`
   - ✅ `github-pat`
   - ✅ `sonarqube-token`
   - ✅ `ecr-credentials`
   - ✅ `slack-webhook`

📸 **SCREENSHOT #3**: Credentials page
- Show all 5 credentials with IDs visible
- Values should be masked/hidden ✅

---

## PHASE 6: CONFIGURE GITHUB PLUGIN (10 minutes)

### Step 6.1: Configure GitHub Server

1. Click **"Manage Jenkins"**
2. Click **"Configure System"**
3. Scroll down to **"GitHub"** section
4. Click **"Add GitHub Server"**

---

### Step 6.2: Enter GitHub Configuration

1. **GitHub Server**: Keep default or enter a name
2. **API URL**: `https://api.github.com` (for GitHub.com)
3. **Credentials**: Select **`github-pat`** from dropdown
4. Click **"Test connection"** - should show ✅ 
5. Click **"Save"**

---

### Step 6.3: Verify Configuration Saved

1. Go back to **"Manage Jenkins"** > **"Configure System"**
2. Scroll to GitHub section
3. Should show your GitHub server configured ✅

---

## PHASE 7: CONFIGURE BUILD AGENT (20 minutes)

### Step 7.1: Generate SSH Key on Agent

```powershell
# SSH to Jenkins agent
ssh -i ~/.ssh/your-key.pem ec2-user@10.0.2.50

# Create .ssh directory
mkdir -p ~/.ssh

# Generate key pair (press Enter for all prompts)
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# View public key
cat ~/.ssh/id_rsa.pub
```

📋 **Copy the entire public key** (starts with `ssh-rsa`)

---

### Step 7.2: Add Public Key to Controller

```powershell
# Still on agent, create authorized_keys
echo "PASTE_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys

# Set correct permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# Verify connection works (from controller to agent)
ssh -o StrictHostKeyChecking=no jenkins@10.0.2.50 "echo Agent SSH connection successful"
```

✅ Should see: "Agent SSH connection successful"

---

### Step 7.3: Get Agent Private Key

```powershell
# On agent, display private key
cat ~/.ssh/id_rsa
```

📋 **Copy the ENTIRE private key** (from `-----BEGIN RSA PRIVATE KEY-----` to `-----END RSA PRIVATE KEY-----`)

---

### Step 7.4: Create Build Agent in Jenkins

1. In Jenkins, click **"Manage Jenkins"**
2. Click **"Manage Nodes and Clouds"**
3. Click **"New Node"**

Fill in:
- **Node name**: `linux-agent` ← **Must be exactly this**
- **Type**: Select **"Permanent Agent"**
- Click **"Create"**

---

### Step 7.5: Configure Agent Settings

Fill in all fields:

**Remote root directory**: `/var/lib/jenkins`

**Labels**: `linux-agent` ← **Must be exactly this** (used in Jenkinsfiles)

**Usage**: Keep default (Use this node as much as possible)

**Launch method**: Select **"Launch agents via SSH"**

**Host**: `10.0.2.50` (agent private IP from Step 2.3)

**Credentials**: 
- Click "Add" button
- **Kind**: Select **"SSH Username with private key"**
- **Username**: `jenkins`
- **Private key**: Select "Enter directly"
- **Key**: Paste the private key from Step 7.3
- **ID**: `agent-ssh-key`
- Click "Create"
- Then select this credential from the dropdown

**Host Key Verification**: Select **"Non verifying Verification Strategy"**

Scroll down and click **"Save"**

---

### Step 7.6: Verify Agent Is Online

1. Go back to **"Manage Nodes and Clouds"**
2. You should see `linux-agent` listed
3. Click on it
4. Check the status indicator (should be green circle with "online" text)

⏳ **If shows "offline"**: Wait 30 seconds and refresh

⚠️ **If still offline**: 
- Check Jenkins agent logs on controller
- Verify security group allows port 50000
- Check agent has Java installed

📸 **SCREENSHOT #4**: Nodes page
- Show `linux-agent` online and connected

---

## PHASE 8: CREATE AND RUN SANITY-CHECK PIPELINE (10 minutes)

### Step 8.1: Create Jenkins Job

1. From Jenkins Dashboard, click **"New Item"**
2. **Item name**: `sanity-check-pipeline`
3. **Type**: Select **"Pipeline"**
4. Click **"OK"**

---

### Step 8.2: Configure Pipeline

On the configuration page:

**Pipeline section**:
- **Definition**: Select **"Pipeline script"**
- **Script**: Paste entire content from `jenkins/tasks/task1/Jenkinsfile`

Then click **"Save"**

---

### Step 8.3: Run the Pipeline

1. You should see `sanity-check-pipeline` job
2. Click **"Build Now"**

---

### Step 8.4: Monitor Pipeline Execution

1. In "Build History" (left sidebar), click the build number (#1)
2. Click **"Console Output"** to see live logs

**Expected output**:
```
Started by user admin
Running as SYSTEM
Building on linux-agent in workspace /var/lib/jenkins/workspace/sanity-check-pipeline
...
[Pipeline] stage: Check Java
java version "17.0.x"
[Pipeline] stage: Check Git
git version 2.x.x
[Pipeline] stage: Check Docker
Docker version 20.x.x
... (all stages showing versions)
[Pipeline] stage: Echo Hello
Hello from linux-agent
[Pipeline] stage: System Info
... system information ...
[Pipeline] Post Actions
✓ All tools verified successfully on agent
Finished: SUCCESS
```

✅ Last line should show: **`Finished: SUCCESS`**

---

### Step 8.5: Take Final Screenshot

📸 **SCREENSHOT #5**: Successful pipeline build
- Show the Build page with "SUCCESS" badge
- Show last few lines of console output showing all stages passed

---

## PHASE 9: PREPARE SUBMISSION DELIVERABLES (5 minutes)

### Summary of Files You Already Have ✅

These were pre-created in the `jenkins/` folder:

✅ `jenkins/setup.md` - Detailed setup documentation  
✅ `jenkins/plugins.txt` - List of all installed plugins  
✅ `jenkins/controller/` - Terraform files for controller EC2  
✅ `jenkins/agent/` - Terraform files for agent EC2  
✅ `jenkins/scripts/` - User_data scripts  
✅ `jenkins/tasks/task1/Jenkinsfile` - The pipeline you just ran  

### Required Screenshots ✅

Take these 5 screenshots and save them to `jenkins/screenshots/`:

1. **Jenkins Dashboard** - After login
2. **Nodes Page** - Showing `linux-agent` online
3. **Credentials Page** - All 5 credentials with IDs visible
4. **Plugins Page** - Showing required 8 plugins installed
5. **Successful Pipeline Build** - Sanity-check pipeline success

```powershell
# Create screenshots directory
mkdir -p jenkins/screenshots

# Copy screenshots into folder (you'll do this manually)
# File names should be:
# - 01-jenkins-dashboard.png
# - 02-nodes-page.png
# - 03-credentials-page.png
# - 04-plugins-page.png
# - 05-pipeline-success.png
```

---

## ✅ TASK 1 COMPLETION CHECKLIST

Work through this checklist to verify everything is complete:

**Infrastructure** (Phase 1-2):
- [ ] Your IP address found and noted
- [ ] AWS credentials verified working
- [ ] VPC from Assignment 3 exists
- [ ] EC2 key pair exists
- [ ] Controller EC2 instance deployed (Terraform apply successful)
- [ ] Agent EC2 instance deployed (Terraform apply successful)
- [ ] Both instances running and have correct IPs

**Jenkins Setup** (Phase 3-4):
- [ ] Jenkins UI accessible at http://your-ip:8080
- [ ] Admin user created (not default password)
- [ ] Suggested plugins installed
- [ ] All 8 required plugins installed:
  - [ ] Pipeline
  - [ ] Git
  - [ ] GitHub Branch Source
  - [ ] Docker Pipeline
  - [ ] Credentials Binding
  - [ ] Pipeline Utility Steps
  - [ ] SonarQube Scanner
  - [ ] Blue Ocean

**Credentials** (Phase 5):
- [ ] AWS credentials created with ID: `aws-credentials`
- [ ] GitHub PAT credential created with ID: `github-pat`
- [ ] SonarQube credential created with ID: `sonarqube-token`
- [ ] ECR credentials created with ID: `ecr-credentials`
- [ ] Slack webhook created with ID: `slack-webhook`

**GitHub Integration** (Phase 6):
- [ ] GitHub server configured in Jenkins
- [ ] GitHub PAT credential selected and verified

**Build Agent** (Phase 7):
- [ ] Agent EC2 instance has SSH key configured
- [ ] Agent configured in Jenkins with label: `linux-agent`
- [ ] Agent shows as **online** in Nodes page
- [ ] SSH connection verified working

**Pipeline Testing** (Phase 8):
- [ ] Job `sanity-check-pipeline` created
- [ ] Pipeline script from `jenkins/tasks/task1/Jenkinsfile` added
- [ ] Build executed successfully on `linux-agent`
- [ ] All 8 stages completed (Java, Git, Docker, AWS CLI, Terraform, Hello, Workspace, System)
- [ ] Console output shows "SUCCESS"

**Submission** (Phase 9):
- [ ] Screenshot #1: Jenkins Dashboard
- [ ] Screenshot #2: Nodes page with agent online
- [ ] Screenshot #3: Credentials page (5 credentials visible)
- [ ] Screenshot #4: Plugins page (8 required plugins visible)
- [ ] Screenshot #5: Pipeline success build
- [ ] All files committed to repository

---

## 🆘 TROUBLESHOOTING

### Jenkins UI won't load
```powershell
# Check if Jenkins is running
ssh -i ~/.ssh/your-key.pem ec2-user@your-controller-ip
sudo systemctl status jenkins

# Restart if needed
sudo systemctl restart jenkins
```

### Agent shows "offline"
```powershell
# Check agent status
ssh -i ~/.ssh/your-key.pem ec2-user@your-agent-ip
ps aux | grep java

# Check Jenkins logs on controller
sudo tail -f /var/log/jenkins/jenkins.log
```

### Pipeline fails on agent
```powershell
# SSH to agent and check tools
ssh -i ~/.ssh/your-key.pem jenkins@your-agent-private-ip
java -version
git --version
docker --version
aws --version
terraform --version
```

### Credentials not working
- Verify credential ID matches exactly what's in pipeline
- Re-test GitHub connection: Manage Jenkins > Configure System > GitHub > Test Connection
- Verify credentials values are correct (no extra spaces)

---

## 📞 QUICK REFERENCE

**Key IPs to Remember**:
- Controller Public IP: From `terraform apply` output
- Agent Private IP: From `terraform apply` output (10.0.x.x)
- Your IP: From Step 1.1

**Key Credential IDs** (MUST match exactly):
- `aws-credentials`
- `github-pat`
- `sonarqube-token`
- `ecr-credentials`
- `slack-webhook`

**Agent Label** (MUST match exactly):
- `linux-agent`

**SSH Commands**:
```powershell
# Controller
ssh -i ~/.ssh/your-key.pem ec2-user@CONTROLLER_PUBLIC_IP

# Agent (from controller, or via bastion)
ssh -i ~/.ssh/your-key.pem jenkins@AGENT_PRIVATE_IP
```

---

## 🎓 LEARNING POINTS FOR VIVA

Be ready to explain:

1. **Why is the controller in a public subnet?**
   - Users need web access to port 8080

2. **Why is the agent in a private subnet?**
   - Security: isolated, no direct internet access, only SSH from controller

3. **Why label the agent "linux-agent"?**
   - Pipelines use `agent { label 'linux-agent' }` to specify which agent to run on

4. **What does the sanity-check pipeline do?**
   - Verifies all required tools are installed (Java, Git, Docker, AWS CLI, Terraform)
   - Runs on the agent to verify agent connectivity works

5. **Why store credentials in Jenkins, not in code?**
   - Secrets never appear in source code or logs
   - Jenkins encrypts credentials in its database
   - Easy to rotate without code changes

6. **How does Jenkins connect to the agent?**
   - SSH connection on port 50000 (JNLP protocol)
   - Agent initiates outbound connection to controller
   - Uses SSH key for authentication (no passwords)

---

## 🎉 YOU'RE DONE WITH TASK 1!

Congratulations! You now have a fully functional Jenkins CI/CD platform.

**Next Steps**:
1. Take all 5 required screenshots
2. Commit all files to Git repository
3. Verify all screenshots and files are included
4. You're ready to move to Task 2 (Groovy Shared Libraries)

**After Task 1**:
- All subsequent tasks (2-5) will run pipelines on the `linux-agent` you configured
- All credentials you created can be referenced using their IDs
- Jenkins is ready for more complex pipelines

---

**Created**: April 25, 2026  
**Version**: 1.0  
**Status**: Ready to Execute

Good luck! 🚀

---
