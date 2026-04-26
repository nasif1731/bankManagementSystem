# Jenkins Setup Troubleshooting Guide

Quick solutions for common issues during Jenkins setup and deployment.

## Terraform Deployment Issues

### Issue: Terraform fails with "VPC not found"

**Problem**: 
```
Error: No VPCs found matching filter
```

**Causes**:
- Assignment 3 VPC hasn't been created yet
- VPC name doesn't match (check tag:Name)
- Using different AWS region

**Solution**:
1. Verify Assignment 3 VPC exists:
   ```bash
   aws ec2 describe-vpcs --filters Name=tag:Name,Values=banking-vpc
   ```
2. If not found, create it first from `terraform-workspace/task1-vpc/`
3. Verify AWS region matches: Check in `terraform.tfvars`
4. Update VPC name if different: Edit `vpc_name` in `terraform.tfvars`

### Issue: Terraform apply fails with "InsufficientInstanceCapacity"

**Problem**:
```
Error: InsufficientInstanceCapacity
```

**Causes**:
- Chosen availability zone has no capacity
- Instance type not available in region
- AWS account has resource quotas

**Solution**:
1. Try different instance type:
   ```terraform
   instance_type = "t3.small"  # Instead of t3.medium
   ```
2. Let Terraform choose AZ automatically (remove explicit AZ if specified)
3. Try different AWS region
4. Wait a few minutes and retry

### Issue: "Access Denied" errors during Terraform apply

**Problem**:
```
Error: AccessDenied
```

**Causes**:
- AWS credentials don't have permissions
- IAM user lacks EC2, VPC, IAM permissions
- Session token expired

**Solution**:
1. Verify AWS credentials:
   ```bash
   aws sts get-caller-identity
   ```
2. Check IAM permissions - need:
   - EC2: Full access (ec2:*)
   - VPC: Full access (ec2:*Vpc*, ec2:*Subnet*, ec2:*SecurityGroup*)
   - IAM: Full access (iam:*)
3. Refresh credentials if using temporary keys:
   ```bash
   aws configure
   ```

### Issue: Terraform state corruption

**Problem**:
```
Error reading state file: json.SyntaxError
```

**Solution**:
1. Check if state file exists:
   ```bash
   ls -la terraform.tfstate*
   ```
2. If corrupted, backup and recreate:
   ```bash
   cp terraform.tfstate terraform.tfstate.backup
   rm terraform.tfstate terraform.tfstate.lock.hcl
   terraform init
   terraform plan
   ```
3. Import existing resources if needed

## EC2 Instance Issues

### Issue: Instance stops immediately after launch

**Problem**: Instance appears in EC2 console but stopped quickly

**Causes**:
- User data script has errors
- Insufficient disk space
- Memory issues

**Solution**:
1. Check system log in EC2 console:
   - Right-click instance → Monitor and troubleshoot → Get system log
2. Look for errors in bash script
3. Common errors:
   - Missing `set -e` line causing script to continue on error
   - Network issues during installation
4. Check instance type has enough resources (minimum t3.small)

### Issue: Can't SSH to controller

**Problem**:
```
Permission denied (publickey)
```

**Causes**:
- Wrong key file
- Wrong username (should be ec2-user for Amazon Linux 2)
- Security group not allowing port 22
- Your IP not in security group

**Solution**:
```bash
# Verify correct key permissions
chmod 600 jenkins-key.pem

# Correct SSH command
ssh -i jenkins-key.pem ec2-user@<controller_ip>

# If still fails, check security group:
aws ec2 describe-security-groups --group-id <sg-id>

# Verify your IP is allowed:
# Should see: IpProtocol: tcp, FromPort: 22, IpRanges with your IP/32
```

### Issue: Instance doesn't have public IP

**Problem**: Controller instance in public subnet but no public IP

**Causes**:
- `associate_public_ip_address` set to false
- Subnet doesn't have public IP assignment enabled
- Elastic IP not attached

**Solution**:
1. Check Terraform configuration:
   ```terraform
   associate_public_ip_address = true
   enable_eip = true
   ```
2. Apply again:
   ```bash
   terraform apply
   ```
3. If still no IP, enable in subnet:
   ```bash
   aws ec2 modify-subnet-attribute --subnet-id <subnet-id> \
     --map-public-ip-on-launch
   ```

## Jenkins Installation Issues

### Issue: Jenkins won't start after deployment

**Problem**: Jenkins UI shows "Connection refused"

**Causes**:
- Jenkins still initializing (wait 5-10 minutes)
- Port 8080 blocked by firewall
- Jenkins process crashed

**Solution**:
1. SSH to controller and check status:
   ```bash
   ssh -i jenkins-key.pem ec2-user@<ip>
   sudo systemctl status jenkins
   ```
2. If not running, start it:
   ```bash
   sudo systemctl start jenkins
   sudo systemctl enable jenkins
   ```
3. Check logs:
   ```bash
   sudo tail -50 /var/log/jenkins/jenkins.log
   ```
4. If port 8080 occupied:
   ```bash
   sudo lsof -i :8080
   ```
5. Verify security group allows port 8080 from your IP

### Issue: Jenkins hangs on "Starting Jenkins"

**Problem**: Browser shows loading but nothing happens

**Causes**:
- Plugins are still downloading/installing
- System is low on resources
- Network issue

**Solution**:
1. Wait longer (plugins can take 10+ minutes)
2. SSH to instance and check logs:
   ```bash
   sudo tail -f /var/log/jenkins/jenkins.log
   ```
3. Look for "Installing plugin" messages
4. If completely hung, restart:
   ```bash
   sudo systemctl restart jenkins
   ```

### Issue: Initial admin password not working

**Problem**: "Invalid password" when unlocking Jenkins

**Causes**:
- Wrong password file
- Password already used (Jenkins already unlocked)
- Whitespace/copy-paste issues

**Solution**:
1. Get fresh password:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
2. Make sure to copy entire output (no spaces)
3. Paste into Jenkins UI exactly
4. If already unlocked, reset Jenkins:
   ```bash
   sudo systemctl stop jenkins
   sudo rm -rf /var/lib/jenkins/secrets/initialAdminPassword
   sudo systemctl start jenkins
   # Wait a minute
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

### Issue: Plugins won't install

**Problem**: "Plugin installation failed"

**Causes**:
- Network connectivity issues
- Plugin version incompatibility
- Disk space full

**Solution**:
1. Check internet connectivity from Jenkins instance:
   ```bash
   sudo su - jenkins
   curl -I https://plugins.jenkins.io/
   ```
2. Check disk space:
   ```bash
   df -h /var/lib/jenkins
   ```
3. If disk full, increase volume size via EC2 console
4. Try installing plugins one by one (some may have dependencies)
5. Restart Jenkins after plugin failures:
   ```bash
   sudo systemctl restart jenkins
   ```

## Agent Configuration Issues

### Issue: Agent won't connect to controller

**Problem**: Agent shows "Offline" in Manage Nodes

**Causes**:
- SSH keys not configured correctly
- Agent security group blocking traffic
- Wrong agent IP address
- Network connectivity issue

**Solution**:
1. Check agent node logs in Jenkins UI:
   - Click agent name → System Log
2. Verify SSH connectivity from controller:
   ```bash
   sudo su - jenkins
   ssh -v jenkins@<agent_private_ip>
   ```
3. If SSH fails, check:
   - Agent security group allows port 22 from VPC
   - Jenkins user exists on agent
   - SSH key in authorized_keys
4. Verify private IP is correct:
   ```bash
   # From agent
   hostname -I
   ```

### Issue: "Permission denied" when agent tries to run commands

**Problem**: Agent connected but build fails with permission error

**Causes**:
- Jenkins user doesn't have sudo permissions
- Docker group not added for jenkins user
- File permissions on work directory

**Solution**:
1. SSH to agent as jenkins user:
   ```bash
   sudo su - jenkins
   ```
2. Verify Docker access:
   ```bash
   docker ps
   ```
3. If Docker command fails, add to docker group:
   ```bash
   sudo usermod -a -G docker jenkins
   ```
4. Verify sudo without password:
   ```bash
   sudo -l
   ```
5. If needed, check sudoers:
   ```bash
   sudo visudo
   # Should see: jenkins ALL=(ALL) NOPASSWD:ALL
   ```

### Issue: Agent work directory has permission issues

**Problem**: "Permission denied" when writing to workspace

**Causes**:
- Work directory not owned by jenkins user
- Work directory has restrictive permissions

**Solution**:
1. SSH to agent and check:
   ```bash
   sudo su - jenkins
   ls -la /home/jenkins/agent
   ```
2. Fix ownership and permissions:
   ```bash
   sudo chown -R jenkins:jenkins /home/jenkins/agent
   sudo chmod -R 755 /home/jenkins/agent
   ```

## Security Group Issues

### Issue: Can't access Jenkins UI from browser

**Problem**: "Connection refused" or timeout

**Causes**:
- Security group doesn't allow your IP
- Port 8080 has wrong IP restriction
- Controller not running

**Solution**:
1. Check security group rules:
   ```bash
   aws ec2 describe-security-groups --group-id <sg-id>
   ```
2. Verify port 8080 rule shows your IP
3. If you're behind corporate firewall, your IP might be different:
   ```bash
   # Check your real IP
   curl https://ifconfig.me
   ```
4. If IP changed, update security group:
   ```bash
   aws ec2 authorize-security-group-ingress \
     --group-id <sg-id> \
     --protocol tcp \
     --port 8080 \
     --cidr <new-ip>/32
   ```
5. Remove old rule if needed

### Issue: Agent can't reach controller

**Problem**: Agent offline, logs show "Connection refused"

**Causes**:
- Agent security group doesn't allow port 50000 to controller
- Controller's private IP changed
- VPC routing misconfigured

**Solution**:
1. Verify security group rule for port 50000:
   ```bash
   aws ec2 describe-security-groups --group-id <controller-sg-id>
   # Should show: IpProtocol: tcp, FromPort: 50000, IpRanges: VPC CIDR
   ```
2. Verify controller is accessible:
   ```bash
   # From agent
   curl -v telnet://10.0.1.10:50000
   ```

## Credential Issues

### Issue: Credentials not working in pipeline

**Problem**: Build fails with "credential not found" or auth error

**Causes**:
- Credential ID spelled wrong
- Credential doesn't exist
- Credential type wrong

**Solution**:
1. Verify credential exists:
   - Go to Manage Jenkins → Manage Credentials
   - Find the credential by ID
2. Copy exact ID and use in pipeline:
   ```groovy
   withCredentials([
       aws(credentialsId: 'aws-credentials',  // Exact ID
           accessKeyVariable: 'AWS_ACCESS_KEY_ID',
           secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')
   ]) {
       // commands
   }
   ```
3. Verify credential type matches:
   - AWS Credentials for AWS keys
   - Username with password for GitHub/Docker
   - Secret text for tokens

### Issue: AWS credentials not working

**Problem**: "InvalidUserID.Malformed" or "UnauthorizedOperation"

**Causes**:
- AWS keys expired or revoked
- Keys don't have sufficient permissions
- Wrong account/region

**Solution**:
1. Verify keys locally:
   ```bash
   aws sts get-caller-identity
   ```
2. Check key permissions in IAM console
3. If keys are old, generate new ones
4. Update credentials in Jenkins:
   - Go to Manage Credentials
   - Click credential ID
   - Update with new keys
5. Test in pipeline:
   ```groovy
   withCredentials([aws(credentialsId: 'aws-credentials', ...)]) {
       sh 'aws sts get-caller-identity'
   }
   ```

## Sanity Check Pipeline Issues

### Issue: Pipeline runs on controller instead of agent

**Problem**: Console output shows "Built on master" instead of agent name

**Causes**:
- Agent label is wrong
- Agent is offline
- Pipeline doesn't specify agent correctly

**Solution**:
1. Verify agent is online:
   - Manage Jenkins → Manage Nodes
   - Should see "jenkins-agent" as online
2. Check pipeline agent specification:
   ```groovy
   agent {
       label 'linux-agent'  // Must match exactly
   }
   ```
3. Verify node label is correct (case-sensitive):
   - Go to agent in Manage Nodes
   - Check "Labels" field
   - Should exactly match label in pipeline

### Issue: Pipeline fails on tool version check

**Problem**: "java: command not found" or similar

**Causes**:
- Tool not installed (init script didn't complete)
- Tool not in PATH
- Wrong shell being used

**Solution**:
1. SSH to agent and verify tool:
   ```bash
   java -version
   git --version
   docker --version
   ```
2. If tool not found, re-run init script:
   ```bash
   # Get init script from controller
   ssh -i jenkins-key.pem ec2-user@<controller>
   cat jenkins/scripts/jenkins-agent-init.sh | ssh ec2-user@<agent> "bash"
   ```
3. If tool installed but not in PATH:
   ```bash
   which java  # Should return path
   ```

## General Troubleshooting Tips

### 1. Always check logs first

**Jenkins logs**:
```bash
ssh ec2-user@<controller>
sudo tail -100 /var/log/jenkins/jenkins.log
```

**System logs**:
```bash
sudo dmesg | tail -20
```

**Agent logs**:
```bash
sudo tail -100 /var/log/jenkins/agents/linux-agent/agent.log
```

### 2. Use AWS Console for debugging

- EC2 instances page: Verify instances running
- System log: Check for boot errors
- Security groups: Verify rules
- IAM roles: Check attached policies

### 3. Verify network connectivity

```bash
# From one instance to another
telnet <target-ip> <port>
nc -zv <target-ip> <port>
curl -v http://<target-ip>:<port>/

# Check DNS resolution
nslookup <hostname>
dig <hostname>
```

### 4. Test credentials independently

```bash
# Test AWS credentials
aws sts get-caller-identity

# Test Git access
git clone https://github.com/<repo>

# Test Docker
docker pull alpine
```

### 5. Ask for help with specifics

When asking for help, provide:
- Exact error message (copy from logs)
- What you were trying to do
- Steps you've already taken
- Terraform output values
- AWS CLI commands you ran

## Getting Help

If stuck:

1. **Check this guide first** - Most common issues covered
2. **Review logs** - Error messages are usually informative
3. **Check official docs**:
   - Jenkins: https://www.jenkins.io/doc/
   - Terraform: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
   - AWS: https://docs.aws.amazon.com/
4. **Verify prerequisites** - All tools installed and configured
5. **Try again** - Sometimes issues are transient (network, timeouts)

---

**Remember**: Most issues are due to:
1. IP address configuration (my_ip variable)
2. SSH key setup (incorrect or missing)
3. Waiting for initialization (not enough time)
4. Security groups (wrong rules or missing ports)
