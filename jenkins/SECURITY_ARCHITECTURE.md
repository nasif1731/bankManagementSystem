# Jenkins Security Architecture

This document explains the security measures implemented in this Jenkins infrastructure setup.

## Network Security

### VPC Isolation
```
┌─────────────────────────────────────┐
│   AWS VPC: 10.0.0.0/16              │
│   (From Assignment 3)               │
│                                     │
│  ┌──────────────────────────────┐  │
│  │   Public Subnets             │  │
│  │   ├─ 10.0.1.0/24             │  │
│  │   ├─ 10.0.2.0/24             │  │
│  │   └─ Jenkins Controller      │  │
│  │      - Accessible from IP    │  │
│  │      - SSH restricted        │  │
│  │      - Jenkins UI restricted │  │
│  └──────────────────────────────┘  │
│                                     │
│  ┌──────────────────────────────┐  │
│  │   Private Subnets            │  │
│  │   ├─ 10.0.3.0/24             │  │
│  │   ├─ 10.0.4.0/24             │  │
│  │   └─ Jenkins Agent           │  │
│  │      - No public IP          │  │
│  │      - SSH from VPC only     │  │
│  │      - Internet via NAT      │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

### Security Groups

**Jenkins Controller Security Group**:
```
Inbound Rules:
├─ SSH (22) from YOUR_IP/32 ONLY
├─ HTTP (8080) from YOUR_IP/32 ONLY
├─ Agent communication (50000) from VPC (10.0.0.0/16)
└─ JNLP (50000) from VPC (10.0.0.0/16)

Outbound Rules:
└─ All traffic to anywhere (for updates, downloads, AWS API)
```

**Jenkins Agent Security Group**:
```
Inbound Rules:
├─ SSH (22) from VPC (10.0.0.0/16)
└─ JNLP (50000) from VPC (10.0.0.0/16)

Outbound Rules:
└─ All traffic to anywhere (for Docker pulls, Git clone, AWS API)
```

### Why This Design?

1. **Controller in Public Subnet**:
   - Needs to be accessible by users
   - Restricted by security group to specific IP
   - Has public IP for Jenkins UI access

2. **Agent in Private Subnet**:
   - No direct internet access
   - Communicates with controller via SSH tunnel
   - Uses NAT Gateway for outbound internet
   - More secure for sensitive operations

3. **Port Restrictions**:
   - SSH (22): Only your IP can access
   - Jenkins UI (8080): Only your IP can access
   - Agent communication (50000): VPC-internal only

## Authentication & Authorization

### Jenkins User Credentials

1. **Admin User Account**:
   - Strong password created during setup wizard
   - Used to log in to Jenkins UI
   - Can create additional users if needed
   - Credentials stored in Jenkins database

2. **SSH Key for Agent Communication**:
   - Generated for jenkins user on controller
   - Private key in `/home/jenkins/.ssh/id_rsa` (controller)
   - Public key in `/home/jenkins/.ssh/authorized_keys` (agent)
   - Key-based authentication (not password)
   - More secure than password authentication

### Jenkins Credentials System

Jenkins securely stores all credentials:

1. **AWS Credentials**:
   - Access Key ID
   - Secret Access Key
   - Stored encrypted in Jenkins database
   - Referenced as `aws-credentials` in pipelines
   - Never displayed in logs

2. **GitHub PAT**:
   - Personal Access Token
   - Encrypted in Jenkins
   - Used for Git operations and GitHub API
   - Referenced as `github-pat`

3. **SonarQube Token**:
   - Authentication for SonarQube
   - Encrypted in Jenkins
   - Referenced as `sonarqube-token`

4. **Docker/ECR Credentials**:
   - AWS credentials for ECR authentication
   - Encrypted in Jenkins
   - Referenced as `ecr-credentials`

5. **Slack Webhook**:
   - Webhook URL for notifications
   - Encrypted in Jenkins
   - Referenced as `slack-webhook`

### Credentials Binding in Pipelines

```groovy
pipeline {
    stages {
        stage('Build') {
            steps {
                // Credentials are bound but not exposed
                withCredentials([
                    aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                        credentialsId: 'aws-credentials')
                ]) {
                    sh '''
                        # Environment variables are available
                        echo "Access Key: ${AWS_ACCESS_KEY_ID:0:4}***"
                        # Full key never printed to logs
                    '''
                }
            }
        }
    }
}
```

**Key Security Points**:
- Credentials passed as environment variables (masked in logs)
- Never appear in console output
- Automatically masked by Jenkins
- Only available during build step

## Data Protection

### Encrypted Storage

1. **EBS Volumes**:
   - Both controller and agent use encrypted EBS volumes
   - Encryption type: AES-256
   - Data encrypted at rest

2. **Jenkins Home Directory**:
   - Located at `/var/lib/jenkins`
   - Owned by jenkins user
   - Permissions: 700 (only jenkins can read)
   - Contains encrypted credentials

3. **SSH Keys**:
   - Private keys stored locally (not shared)
   - Permissions: 600 (read/write owner only)
   - Never transmitted in plaintext

### Logs and Monitoring

1. **Console Output**:
   - Secrets are masked in logs
   - Jenkins masks known credentials
   - Example: `****` shown instead of actual value

2. **CloudWatch Logs**:
   - Jenkins logs sent to CloudWatch
   - Retention: 7 days
   - Encrypted at rest
   - Access controlled via IAM

3. **Build Artifacts**:
   - Stored in Jenkins workspace
   - Accessible only to jenkins user
   - Cleaned up according to retention policy

## IAM Security

### Controller IAM Role

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
```

**Why Full Access?**:
- Jenkins needs to manage AWS resources (EC2, ECR, S3, etc.)
- Drives Terraform for infrastructure
- Pushes images to ECR
- Reads/writes S3 buckets

**In Production**:
- Consider least-privilege principle
- Create specific policies per service
- Example: ECR policy only allows ECR operations

### Agent IAM Role

Same as controller (full AWS access) because:
- Agent needs to run Terraform
- Agent needs to deploy to AWS
- Agent builds and pushes Docker images

## SSH Security

### Key-Based Authentication Only

No passwords used for SSH - only keys:

1. **Controller Access**:
   - Requires `jenkins-key.pem` from EC2 key pair
   - Only your IP can connect
   - SSH command: `ssh -i jenkins-key.pem ec2-user@<controller_ip>`

2. **Agent Communication**:
   - Jenkins user key: `/home/jenkins/.ssh/id_rsa`
   - Password-less sudo for jenkins user
   - Allows controller to execute commands on agent

### Security Best Practices

1. **Never share key pair**:
   ```bash
   # Correct: Keep key private
   chmod 600 jenkins-key.pem
   ```

2. **Don't use default SSH settings**:
   ```bash
   # SSH to specific key only
   ssh -i jenkins-key.pem ec2-user@<ip>
   ```

3. **Use SSH config for convenience**:
   ```bash
   # ~/.ssh/config
   Host jenkins-controller
       HostName <controller_ip>
       User ec2-user
       IdentityFile ~/.ssh/jenkins-key.pem
   ```

## Credential Management Best Practices

### What NOT to Do

❌ Don't hardcode credentials in:
- Jenkinsfiles
- Scripts
- Configuration files
- Environment variables (visible in UI)

❌ Don't commit credentials to Git:
- AWS keys
- GitHub tokens
- Private keys
- Passwords

❌ Don't print secrets to console:
```groovy
// WRONG:
sh 'echo $AWS_SECRET_KEY'  // Will be masked but bad practice

// RIGHT:
withCredentials([...]) {
    sh 'aws s3 ls'  // Uses credential but doesn't print it
}
```

### What TO Do

✓ Use Jenkins Credentials System
```groovy
withCredentials([
    aws(credentialsId: 'aws-credentials',
        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')
]) {
    // Use $AWS_ACCESS_KEY_ID and $AWS_SECRET_ACCESS_KEY
}
```

✓ Use environment variables
```groovy
environment {
    AWS_REGION = 'us-east-1'  // Non-sensitive
}
```

✓ Keep sensitive data in Jenkins credentials
- AWS keys
- GitHub tokens
- Database passwords
- API tokens

✓ Use .gitignore to prevent accidental commits
```
*.pem
*.key
*.tfstate
.env
credentials.txt
```

## Monitoring and Auditing

### What to Monitor

1. **Jenkins Logs**:
   - Authentication attempts
   - Build failures
   - Plugin updates
   - System errors

2. **AWS CloudTrail**:
   - Who accessed what resources
   - When resources were created/modified
   - Failed operations

3. **Agent Connectivity**:
   - Agent online/offline status
   - SSH connection issues
   - Resource utilization

### Access Logs

Jenkins logs important events:
- User logins
- Job executions
- Credential access
- Plugin updates

Location: `/var/log/jenkins/jenkins.log`

## Security Checklist

Before deploying to production:

- [ ] **Network**:
  - [ ] Controller in public subnet with restricted access
  - [ ] Agent in private subnet
  - [ ] Security groups follow least privilege
  - [ ] SSH restricted to authorized IPs

- [ ] **Authentication**:
  - [ ] Strong Jenkins admin password
  - [ ] SSH key-based, not passwords
  - [ ] Credentials stored in Jenkins, not in code
  - [ ] PAT tokens with minimal scopes

- [ ] **Authorization**:
  - [ ] Jenkins roles configured (if multiple users)
  - [ ] IAM roles follow least privilege principle
  - [ ] Credentials accessible only to authorized jobs

- [ ] **Data Protection**:
  - [ ] EBS volumes encrypted
  - [ ] Jenkins home encrypted
  - [ ] SSH keys with 600 permissions
  - [ ] Secrets masked in logs

- [ ] **Operations**:
  - [ ] CloudWatch logs configured
  - [ ] Backups of Jenkins home configured
  - [ ] Monitoring alerts set up
  - [ ] Audit trail maintained

- [ ] **Compliance**:
  - [ ] No hardcoded secrets in code
  - [ ] No credentials in Git history
  - [ ] Access logs reviewed regularly
  - [ ] Incident response plan in place

## Security Updates

### Keeping Jenkins Secure

1. **Regular Updates**:
   - Jenkins updates: Check monthly
   - Plugin updates: Check weekly
   - OS patches: Install promptly

2. **Security Scanning**:
   - SonarQube for code vulnerabilities
   - Docker image scanning before push
   - Dependency checking (e.g., npm audit)

3. **Audit Logging**:
   - Enable Jenkins audit logging
   - Review logs weekly
   - Monitor for suspicious activity

## Additional Security Resources

- [OWASP Jenkins Security Handbook](https://owasp.org/)
- [CIS Jenkins Benchmarks](https://www.cisecurity.org/)
- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)

## Questions for the Viva

Be prepared to answer:

1. **Why is controller in public subnet but agent in private?**
   - Controller needs UI access
   - Agent runs sensitive operations, isolated from internet

2. **How are credentials protected?**
   - Stored encrypted in Jenkins database
   - Masked in logs
   - Bound as environment variables

3. **What happens if a key is compromised?**
   - Delete the EC2 key pair
   - Create new key pair
   - Re-deploy EC2 instances
   - Regenerate SSH keys

4. **Why use SSH keys instead of passwords?**
   - More secure (longer, random)
   - Can't be guessed or brute-forced
   - Can be automatically rotated
   - Industry standard practice

5. **How do you prevent accidental secret commits?**
   - .gitignore for sensitive files
   - Git hooks to scan for secrets
   - Pre-commit checks
   - Review processes

---

This security architecture ensures Jenkins is production-ready with multiple layers of protection.
