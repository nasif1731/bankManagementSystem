# Task 1 Completion Checklist

This checklist will help you track your progress through Task 1: Jenkins Installation and Basic Configuration.

## Pre-Deployment Setup

- [ ] **Have your IP address ready** in CIDR format (e.g., `203.0.113.42/32`)
  - To find your IP: Visit https://ifconfig.me or ask your ISP
  - Format: `xxx.xxx.xxx.xxx/32` for your single IP

- [ ] **Create AWS resources**:
  - [ ] EC2 key pair created (e.g., `jenkins-key`)
  - [ ] Key pair downloaded and saved locally

- [ ] **Prepare credentials** (you'll need these later):
  - [ ] GitHub Personal Access Token (PAT)
    - Go to: GitHub → Settings → Developer Settings → Personal Access Tokens
    - Select scopes: `repo`, `admin:repo_hook`
  - [ ] AWS Access Key ID and Secret Key
    - Go to: IAM → Users → Access Keys
  - [ ] Slack webhook URL (if planning to use Slack)
    - Set up incoming webhook in Slack workspace
  - [ ] SonarQube token (for later tasks)

- [ ] **Update Terraform configuration**:
  - [ ] Edit `jenkins/controller/terraform.tfvars`
  - [ ] Update `my_ip = "YOUR.IP.ADDRESS/32"`
  - [ ] Verify AWS region matches your Assignment 3 VPC region

## Infrastructure Deployment

- [ ] **Deploy using provided helper script** (Recommended):
  ```bash
  cd jenkins
  chmod +x deploy.sh
  ./deploy.sh check              # Verify prerequisites
  ./deploy.sh deploy-all         # Deploy controller and agent
  ```

- **OR Deploy manually**:
  - [ ] **Controller deployment**:
    - [ ] Navigate to `jenkins/controller`
    - [ ] Run `terraform init`
    - [ ] Run `terraform plan`
    - [ ] Run `terraform apply`
    - [ ] Save outputs (especially `jenkins_url` and `ssh_command`)
    - [ ] Wait 5-10 minutes for Jenkins to start
  
  - [ ] **Agent deployment**:
    - [ ] Navigate to `jenkins/agent`
    - [ ] Run `terraform init`
    - [ ] Run `terraform plan`
    - [ ] Run `terraform apply`
    - [ ] Save outputs (especially `jenkins_agent_private_ip`)

- [ ] **Verify EC2 instances**:
  - [ ] Controller instance is running in public subnet
  - [ ] Agent instance is running in private subnet
  - [ ] Both have correct security groups assigned
  - [ ] Both are in the correct VPC (10.0.0.0/16)

## Jenkins UI Setup (Manual - 30 minutes)

- [ ] **Access Jenkins**:
  - [ ] Open browser to Jenkins URL (from Terraform outputs)
  - [ ] See Jenkins unlock page

- [ ] **Unlock Jenkins**:
  - [ ] SSH to controller: `ssh -i jenkins-key.pem ec2-user@<ip>`
  - [ ] Run: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
  - [ ] Paste password in unlock page

- [ ] **Install Suggested Plugins**:
  - [ ] See "Install suggested plugins" button
  - [ ] Click it
  - [ ] Wait for installation (5-10 minutes)

- [ ] **Install Required Plugins**:
  - [ ] Go to **Manage Jenkins** → **Manage Plugins** → **Available**
  - [ ] Install these plugins:
    - [ ] Pipeline
    - [ ] Git
    - [ ] GitHub Branch Source
    - [ ] Docker Pipeline
    - [ ] Credentials Binding
    - [ ] Pipeline Utility Steps
    - [ ] SonarQube Scanner
    - [ ] Blue Ocean
  - [ ] Restart Jenkins after plugins are installed
    - Go to **Manage Jenkins** → Scroll down → **Restart Jenkins**

- [ ] **Create Admin User**:
  - [ ] Username: (Choose strong username)
  - [ ] Password: (Choose strong password - don't reuse others!)
  - [ ] Full Name: (Your name or "Jenkins Administrator")
  - [ ] Email: (Your email)
  - [ ] Click **Save and Finish**

- [ ] **Verify Jenkins is Ready**:
  - [ ] Log in with new admin credentials
  - [ ] See Jenkins dashboard
  - [ ] No error messages

## Configure Credentials

- [ ] **Create AWS Credentials**:
  - [ ] Go to **Manage Jenkins** → **Manage Credentials** → **Global**
  - [ ] Click **Add Credentials**
  - [ ] **Kind**: `AWS Credentials`
  - [ ] **ID**: `aws-credentials`
  - [ ] **Access Key ID**: (Your AWS access key)
  - [ ] **Secret Access Key**: (Your AWS secret key)
  - [ ] Click **Create**

- [ ] **Create GitHub PAT**:
  - [ ] Click **Add Credentials**
  - [ ] **Kind**: `Username with password`
  - [ ] **Username**: (Your GitHub username)
  - [ ] **Password**: (Your GitHub PAT)
  - [ ] **ID**: `github-pat`
  - [ ] Click **Create**

- [ ] **Create SonarQube Token** (for later, but create now):
  - [ ] Click **Add Credentials**
  - [ ] **Kind**: `Secret text`
  - [ ] **Secret**: (Your SonarQube token)
  - [ ] **ID**: `sonarqube-token`
  - [ ] Click **Create**

- [ ] **Create Docker/ECR Credentials**:
  - [ ] Click **Add Credentials**
  - [ ] **Kind**: `Username with password`
  - [ ] **Username**: `AWS`
  - [ ] **Password**: (Your AWS secret key or use AWS temp credentials)
  - [ ] **ID**: `ecr-credentials`
  - [ ] Click **Create**

- [ ] **Create Slack Webhook** (Optional):
  - [ ] Click **Add Credentials**
  - [ ] **Kind**: `Secret text`
  - [ ] **Secret**: (Your Slack webhook URL)
  - [ ] **ID**: `slack-webhook`
  - [ ] Click **Create**

- [ ] **Verify Credentials**:
  - [ ] Go to **Manage Credentials** → **Global**
  - [ ] Verify all 5 credentials are listed
  - [ ] Verify IDs are visible (values should be masked)

## Configure GitHub Plugin

- [ ] **Configure GitHub Connection**:
  - [ ] Go to **Manage Jenkins** → **System**
  - [ ] Find **GitHub** section
  - [ ] Click **Add GitHub Server**
  - [ ] **GitHub Server**: `https://api.github.com`
  - [ ] **Credentials**: Select `github-pat`
  - [ ] Click **Test Connection**
  - [ ] Should see: "Credentials verified for user: <username>"
  - [ ] Click **Save**

## Configure Build Agent

- [ ] **Set up SSH Keys**:
  - [ ] SSH to controller
  - [ ] Switch to jenkins user: `sudo su - jenkins`
  - [ ] Generate SSH key: `ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa`
  - [ ] Display public key: `cat ~/.ssh/id_rsa.pub`
  - [ ] Copy the public key output

- [ ] **Add Key to Agent**:
  - [ ] SSH to agent (via SSM Session Manager or jump host)
  - [ ] Switch to jenkins user: `sudo su - jenkins`
  - [ ] Create .ssh directory: `mkdir -p ~/.ssh && chmod 700 ~/.ssh`
  - [ ] Add public key: `echo '<paste_key_here>' >> ~/.ssh/authorized_keys`
  - [ ] Set permissions: `chmod 600 ~/.ssh/authorized_keys`

- [ ] **Test SSH Connection**:
  - [ ] From controller: `sudo su - jenkins`
  - [ ] Try SSH to agent: `ssh -i ~/.ssh/id_rsa jenkins@<agent_private_ip>`
  - [ ] Should succeed and show agent prompt
  - [ ] Exit and return to controller

- [ ] **Add Agent in Jenkins UI**:
  - [ ] Go to **Manage Jenkins** → **Manage Nodes and Clouds**
  - [ ] Click **New Node**
  - [ ] **Node name**: `linux-agent`
  - [ ] **Type**: `Permanent Agent`
  - [ ] Click **Create**
  - [ ] Configure:
    - [ ] **Remote root directory**: `/home/jenkins/agent`
    - [ ] **Labels**: `linux-agent`
    - [ ] **Usage**: `Use this node as much as possible`
    - [ ] **Launch method**: `Launch agents via SSH`
      - [ ] **Host**: (Agent private IP)
      - [ ] **Credentials**: Create new SSH credentials
        - [ ] **Username**: `jenkins`
        - [ ] **Private Key**: Paste content of `/home/jenkins/.ssh/id_rsa` from controller
        - [ ] **ID**: `jenkins-ssh-key`
  - [ ] Click **Save**
  - [ ] Wait for agent to connect (should show "Agent is connected and online")

- [ ] **Verify Agent is Online**:
  - [ ] Go to **Manage Nodes** (or refresh page)
  - [ ] See `linux-agent` listed as **online**
  - [ ] No error symbols or disconnected status

## Create Sanity-Check Pipeline

- [ ] **Create New Pipeline Job**:
  - [ ] Click **New Item**
  - [ ] **Name**: `sanity-check-pipeline`
  - [ ] **Type**: `Pipeline`
  - [ ] Click **OK**

- [ ] **Configure Pipeline**:
  - [ ] Go to **Pipeline** section
  - [ ] Select **Pipeline script** (not from SCM)
  - [ ] Paste content from `jenkins/Jenkinsfile.sanity-check`
  - [ ] Click **Save**

- [ ] **Run Pipeline**:
  - [ ] Click **Build Now**
  - [ ] Monitor build in **Build History**
  - [ ] Click on build number to view console output

- [ ] **Verify Success**:
  - [ ] Pipeline should complete without errors
  - [ ] Console output should show:
    - [ ] Agent hostname (should be different from controller)
    - [ ] User: `jenkins`
    - [ ] Java version
    - [ ] Git version
    - [ ] Docker version
    - [ ] AWS CLI version
    - [ ] Terraform version
    - [ ] SUCCESS message at end

## Take Screenshots (for Deliverables)

- [ ] **Jenkins Dashboard**:
  - [ ] Screenshot of dashboard after login
  - [ ] Save as: `dashboard.png`

- [ ] **Manage Nodes Page**:
  - [ ] Go to **Manage Jenkins** → **Manage Nodes and Clouds**
  - [ ] Screenshot showing agent online
  - [ ] Save as: `nodes-page.png`

- [ ] **Credentials Page**:
  - [ ] Go to **Manage Jenkins** → **Manage Credentials** → **Global**
  - [ ] Screenshot showing all 5 credentials (IDs visible, values masked)
  - [ ] Save as: `credentials-page.png`

- [ ] **Plugins Page**:
  - [ ] Go to **Manage Jenkins** → **Manage Plugins** → **Installed**
  - [ ] Screenshot showing required plugins
  - [ ] Take multiple screenshots if needed to show all plugins
  - [ ] Save as: `plugins-page-1.png`, `plugins-page-2.png`, etc.

- [ ] **Sanity-Check Pipeline Success**:
  - [ ] Go to the `sanity-check-pipeline` job
  - [ ] Click on the successful build
  - [ ] Screenshot of console output (at least the success message)
  - [ ] Save as: `pipeline-success.png`

## Documentation

- [ ] **Verify All Files Created**:
  - [ ] `jenkins/README.md` - Main overview ✓
  - [ ] `jenkins/setup.md` - Detailed setup guide ✓
  - [ ] `jenkins/plugins.txt` - Plugin list ✓
  - [ ] `jenkins/controller/main.tf` - Controller infrastructure ✓
  - [ ] `jenkins/controller/variables.tf` - Controller variables ✓
  - [ ] `jenkins/controller/outputs.tf` - Controller outputs ✓
  - [ ] `jenkins/controller/terraform.tfvars` - Controller config ✓
  - [ ] `jenkins/agent/main.tf` - Agent infrastructure ✓
  - [ ] `jenkins/agent/variables.tf` - Agent variables ✓
  - [ ] `jenkins/agent/outputs.tf` - Agent outputs ✓
  - [ ] `jenkins/agent/terraform.tfvars` - Agent config ✓
  - [ ] `jenkins/scripts/jenkins-controller-init.sh` - Controller init ✓
  - [ ] `jenkins/scripts/jenkins-agent-init.sh` - Agent init ✓
  - [ ] `jenkins/Jenkinsfile.sanity-check` - Sample pipeline ✓
  - [ ] `jenkins/SHARED_LIBRARY_REFERENCE.md` - Library reference ✓

- [ ] **Create Final Report**:
  - [ ] Document all setup steps taken
  - [ ] Include IP addresses and instance IDs
  - [ ] Include selected plugin names
  - [ ] Document any customizations made
  - [ ] List all credentials created (without values!)
  - [ ] Note any challenges encountered and how resolved

## Final Verification

- [ ] **All Terraform Outputs Saved**:
  - [ ] Controller: `jenkins_url`, `ssh_command`, instance ID
  - [ ] Agent: Private IP, work directory, label

- [ ] **All Screenshots Collected**:
  - [ ] Dashboard login
  - [ ] Nodes page with agent online
  - [ ] Credentials page with all 5 credentials
  - [ ] Plugins page showing required plugins
  - [ ] Sanity-check pipeline success

- [ ] **Jenkinsfile Understanding**:
  - [ ] You can explain each stage
  - [ ] You can modify a stage
  - [ ] You can trace through the logic
  - [ ] You understand why it runs on agent, not controller

- [ ] **Ready for Viva**:
  - [ ] You can explain the infrastructure
  - [ ] You can describe security measures
  - [ ] You can explain credential management
  - [ ] You understand Jenkins agent setup
  - [ ] You can troubleshoot issues

## Deliverables Summary

For submission, you need:

1. **Terraform Infrastructure Files** (in jenkins/ folder):
   - controller/ and agent/ directories with all .tf files
   - scripts/ directory with user_data scripts
   - setup.md with detailed instructions
   - plugins.txt with installed plugins

2. **Screenshots** (at least 5):
   - Jenkins dashboard
   - Manage Nodes page
   - Credentials page
   - Plugins page
   - Sanity-check pipeline success

3. **Documentation**:
   - README.md explaining structure
   - setup.md with step-by-step guide
   - Brief notes on security measures

4. **Functional Pipeline**:
   - Sanity-check pipeline that echoes "hello" on agent
   - Pipeline succeeds and shows all tool versions
   - Screenshots of successful run

## Notes

- **Keep secrets secure**: Never commit AWS keys, GitHub tokens, or passwords
- **Your IP is critical**: Without correct `my_ip`, you won't access Jenkins
- **Agent must be online**: Core requirement for pipeline execution
- **All plugins must install**: Required for later tasks
- **Understand the setup**: Viva will test your knowledge

---

**Expected Time**: 2-3 hours for full setup from scratch
**Main Blocker**: Waiting for EC2 instances to start (~10 minutes each)
**Critical Actions**: Update my_ip, configure SSH keys, verify agent connection
