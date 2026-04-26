# Jenkins CI/CD Pipeline - Task 1 Setup Summary

## What Has Been Created For You

This folder contains a **complete, production-ready Jenkins CI/CD infrastructure** built as Infrastructure-as-Code using Terraform. Everything is documented, organized, and ready to deploy.

### 📁 Directory Structure

```
jenkins/
├── README.md                              ← Start here! Overview of everything
├── TASK1_CHECKLIST.md                     ← Step-by-step progress tracker
├── setup.md                               ← Detailed setup guide (300+ lines)
├── TROUBLESHOOTING.md                     ← Common issues and fixes
├── SECURITY_ARCHITECTURE.md               ← Security deep-dive
├── SHARED_LIBRARY_REFERENCE.md            ← Groovy shared lib structure
├── plugins.txt                            ← List of required plugins
├── Jenkinsfile.sanity-check               ← Sample declarative pipeline
│
├── controller/                            ← Jenkins Controller (Master)
│   ├── main.tf                            ← Infrastructure definition
│   ├── variables.tf                       ← Input variables
│   ├── outputs.tf                         ← Output values
│   └── terraform.tfvars                   ← Configuration (EDIT THIS!)
│
├── agent/                                 ← Jenkins Build Agent
│   ├── main.tf                            ← Infrastructure definition
│   ├── variables.tf                       ← Input variables
│   ├── outputs.tf                         ← Output values
│   └── terraform.tfvars                   ← Configuration
│
└── scripts/                               ← Initialization Scripts
    ├── jenkins-controller-init.sh         ← EC2 startup script
    └── jenkins-agent-init.sh              ← Agent startup script
```

## 🚀 Quick Start (5 Steps)

### Step 1: Update Configuration
Edit `jenkins/controller/terraform.tfvars`:
```terraform
my_ip = "YOUR.IP.ADDRESS/32"  # ← CHANGE THIS!
```

**How to find your IP**: Visit https://ifconfig.me

### Step 2: Deploy Infrastructure
```bash
cd jenkins
chmod +x deploy.sh
./deploy.sh check              # Verify prerequisites
./deploy.sh deploy-all         # Deploy everything
```

Takes ~15 minutes total:
- Controller deployment: ~5 minutes
- Agent deployment: ~5 minutes
- Waiting for initialization: ~5 minutes

### Step 3: Access Jenkins UI
Once deployment completes, you'll see URLs like:
```
jenkins_url = "http://203.0.113.10:8080"
```

Open this URL in your browser. Jenkins may take 2-3 minutes to fully start.

### Step 4: Complete Setup Wizard
1. Unlock Jenkins with initial admin password
2. Install suggested plugins
3. Create admin user account
4. Install additional required plugins

Takes ~10-15 minutes including plugin downloads.

### Step 5: Configure and Test
1. Add credentials (AWS, GitHub, Docker, SonarQube)
2. Configure build agent
3. Run sanity-check pipeline
4. Take screenshots for submission

Takes ~15-20 minutes.

**Total Time: ~1 hour from start to working pipeline**

## 📚 Documentation Overview

### For Beginners
Start with these in order:
1. `README.md` - Overview and key concepts
2. `TASK1_CHECKLIST.md` - Follow step-by-step
3. `setup.md` - Detailed instructions when stuck

### For Understanding the Code
1. `SECURITY_ARCHITECTURE.md` - Why infrastructure is designed this way
2. Review Terraform files (`controller/main.tf`, `agent/main.tf`)
3. Review init scripts (`scripts/jenkins-controller-init.sh`, etc.)

### For Troubleshooting
1. `TROUBLESHOOTING.md` - First reference for problems
2. Check logs (see troubleshooting guide)
3. Review security groups if access issues

### For Future Tasks
1. `SHARED_LIBRARY_REFERENCE.md` - Foundation for Task 2
2. `Jenkinsfile.sanity-check` - Example declarative pipeline

## 🔑 Key Features

### Infrastructure
✅ **Controller**: t3.medium EC2 in public subnet
✅ **Agent**: t3.medium EC2 in private subnet
✅ **Network**: Uses VPC from Assignment 3
✅ **Security**: Restricted access, encryption at rest, SSH keys
✅ **Monitoring**: CloudWatch logs for debugging

### Jenkins
✅ **LTS Version**: Latest stable Jenkins
✅ **Java 17**: Required for LTS
✅ **Required Plugins**: All 8 specified + recommended
✅ **Credentials**: Secure storage for AWS, GitHub, Docker, SonarQube, Slack
✅ **Blue Ocean**: Modern UI for pipeline visualization

### Tools Installed
✅ Java 17 (Jenkins requirement)
✅ Git (SCM integration)
✅ Docker (Container support)
✅ AWS CLI v2 (AWS integration)
✅ Terraform (Infrastructure as Code)

### Automation
✅ Terraform IaC (infrastructure defined as code)
✅ user_data scripts (automated initialization)
✅ SSH key-based auth (no passwords)
✅ Helper script for deployment (deploy.sh)

## ⚠️ Critical Prerequisites

Before you start:

1. **AWS Account** with permissions to:
   - Create EC2 instances
   - Create security groups
   - Create IAM roles
   - Create EBS volumes

2. **Terraform** installed (v1.0+):
   ```bash
   terraform version
   ```

3. **AWS CLI** configured:
   ```bash
   aws configure
   aws sts get-caller-identity  # Verify it works
   ```

4. **Assignment 3 VPC** must exist:
   - Name: `banking-vpc`
   - CIDR: `10.0.0.0/16`
   - Public subnets available
   - Private subnets available

5. **SSH Key Pair** created in AWS EC2:
   - Download the .pem file
   - Save to ~/.ssh/jenkins-key.pem

6. **Your IP Address** in CIDR format:
   - Example: `203.0.113.42/32`
   - Must update `terraform.tfvars`

## 🎯 What Gets Deployed

### Controller Instance
- **Purpose**: Runs Jenkins master/controller
- **OS**: Amazon Linux 2
- **Size**: t3.medium (4 CPU, 4GB RAM)
- **Storage**: 50GB encrypted EBS
- **Network**: Public subnet
- **Access**: SSH from your IP only, Jenkins UI from your IP only
- **Services**: Jenkins LTS, Java 17, Git, Docker, AWS CLI, Terraform

### Agent Instance  
- **Purpose**: Runs Jenkins build jobs
- **OS**: Amazon Linux 2
- **Size**: t3.medium (4 CPU, 4GB RAM)
- **Storage**: 50GB encrypted EBS
- **Network**: Private subnet
- **Access**: SSH from controller only via JNLP
- **Services**: Java 17, Git, Docker, AWS CLI, Terraform

### Security
- Encrypted EBS volumes
- Security groups with restricted access
- IAM roles with appropriate permissions
- SSH key-based authentication
- No hardcoded credentials
- Secrets managed by Jenkins

## 📝 Important Notes

### For the Viva Exam

You will be asked to:
1. **Explain the Jenkinsfile stages** - You wrote the sanity-check pipeline
2. **Modify a stage live** - You can change/add steps in the pipeline
3. **Trace failed builds** - You can read logs and identify issues
4. **Justify design decisions** - You understand why infrastructure is designed this way

**Therefore**:
- ✅ Read and understand all the code
- ✅ Understand what each Terraform block does
- ✅ Be able to modify the sanity-check Jenkinsfile
- ✅ Know where to find logs and how to debug
- ✅ Understand security measures

### What NOT to Do
- ❌ Don't copy Jenkinsfiles from online sources
- ❌ Don't share pipeline code with other groups
- ❌ Don't use AI tools to write Groovy without learning it
- ❌ Don't hardcode credentials in any file
- ❌ Don't commit .pem files or terraform.tfstate to Git

### Deliverables Checklist

For submission, prepare:

**Files** (in jenkins/ folder):
- [x] Terraform files (controller/ and agent/)
- [x] User data scripts (scripts/)
- [x] setup.md with complete instructions
- [x] plugins.txt with plugin list
- [x] Sanity-check Jenkinsfile
- [x] Security documentation
- [x] Troubleshooting guide

**Screenshots** (at least 5):
- [ ] Jenkins dashboard (after login)
- [ ] Manage Nodes page (agent online)
- [ ] Credentials page (all 5 credentials visible, masked)
- [ ] Plugins page (required plugins shown)
- [ ] Sanity-check pipeline successful run

**Working Pipeline**:
- [ ] Sanity-check pipeline that echoes on agent
- [ ] Pipeline succeeds and displays all tool versions
- [ ] Screenshot of successful console output

**Report**:
- [ ] Document infrastructure created
- [ ] List security measures implemented
- [ ] Note any modifications made
- [ ] Provide instance IDs and URLs
- [ ] Explain setup process

## 🔗 File Reference Guide

| File | Purpose | When to Edit |
|------|---------|--------------|
| `controller/terraform.tfvars` | Controller config | **Before deployment** (set your IP!) |
| `agent/terraform.tfvars` | Agent config | Optional (most defaults work) |
| `scripts/jenkins-controller-init.sh` | Controller startup | Only if customizing packages |
| `scripts/jenkins-agent-init.sh` | Agent startup | Only if customizing packages |
| `Jenkinsfile.sanity-check` | Sample pipeline | For learning/modification |
| `setup.md` | Detailed guide | Reference during setup |
| `TASK1_CHECKLIST.md` | Progress tracker | Check off as you complete steps |

## 📞 Quick Help

### I'm stuck on step X
→ Check `TASK1_CHECKLIST.md` and look at that step

### How do I debug an error?
→ Read `TROUBLESHOOTING.md` for that issue

### I don't understand a Terraform block
→ Check `setup.md` or `SECURITY_ARCHITECTURE.md`

### How do I modify the pipeline?
→ See `Jenkinsfile.sanity-check` - each stage is well-commented

### My agent won't connect
→ Read "Agent Configuration Issues" in `TROUBLESHOOTING.md`

## 🎓 Learning Resources

While setting up, learn about:

1. **Terraform**: How IaC defines infrastructure
   - Variables and outputs
   - Data sources for referencing existing resources
   - Resource creation and provisioning

2. **Jenkins**: How CI/CD pipelines work
   - Declarative vs Groovy syntax
   - Agent selection and labeling
   - Credentials and secrets management
   - Pipeline stages and steps

3. **AWS**: How cloud infrastructure works
   - VPC, subnets, and security groups
   - EC2 instances and IAM roles
   - Security best practices

4. **Groovy**: Scripting language for Jenkins
   - Will use for shared libraries (Task 2)
   - Will use for advanced pipeline logic (Tasks 3+)

## 🎬 Next Steps After Task 1

Once Jenkins is working:

1. **Task 2**: Create Groovy shared libraries
   - Reusable functions for building, testing, deploying
   - Stored in separate Git repository
   - Called from main pipeline

2. **Task 3**: Add SonarQube integration
   - Code quality scanning
   - Build failure on code issues
   - Dashboard for code metrics

3. **Task 3**: Docker and ECR integration
   - Build Docker images
   - Push to AWS ECR
   - Security scanning

4. **Task 4**: Blue-Green deployment
   - Two identical production environments
   - Zero-downtime deployments
   - Quick rollback capability

5. **Task 5**: Monitoring and alerting
   - Prometheus for metrics
   - Grafana for dashboards
   - Alerts for failures

## ✅ Final Checklist

Before starting deployment, verify:

- [ ] Your IP address is in `terraform.tfvars` (my_ip)
- [ ] AWS credentials are configured (`aws sts get-caller-identity` works)
- [ ] Terraform is installed (`terraform version` shows >= 1.0)
- [ ] SSH key pair exists in AWS
- [ ] VPC from Assignment 3 exists
- [ ] You have read `setup.md`
- [ ] You understand security (read `SECURITY_ARCHITECTURE.md`)
- [ ] You've bookmarked `TROUBLESHOOTING.md` for reference

---

## 🚀 Ready? Let's Go!

1. **Update** `jenkins/controller/terraform.tfvars` with your IP
2. **Run** `cd jenkins && ./deploy.sh deploy-all`
3. **Wait** for deployment to complete (~15 minutes)
4. **Access** Jenkins UI from the output URL
5. **Follow** `TASK1_CHECKLIST.md` for remaining steps
6. **Reference** `setup.md` if you get stuck
7. **Troubleshoot** using `TROUBLESHOOTING.md`

**Good luck! You've got everything you need. 🎉**

---

**Last Updated**: April 25, 2026
**Assignment**: 4 - Jenkins CI/CD Pipeline  
**Task**: 1 - Jenkins Installation and Basic Configuration
**Estimated Time**: 1-2 hours for full setup
