# Jenkins CI/CD Infrastructure

This directory contains all the infrastructure-as-code (IaC) and configuration files needed to set up a production-grade Jenkins CI/CD pipeline on AWS.

## Directory Structure

```
jenkins/
├── README.md                       # This file
├── setup.md                        # Detailed step-by-step setup guide
├── plugins.txt                     # List of required Jenkins plugins
│
├── controller/                     # Jenkins Controller (Master) Infrastructure
│   ├── main.tf                     # Main Terraform configuration
│   ├── variables.tf                # Input variables
│   ├── outputs.tf                  # Output values (IPs, DNS, etc.)
│   ├── terraform.tfvars            # Variable values (CUSTOMIZE THIS)
│   └── README.md                   # Controller-specific notes
│
├── agent/                          # Jenkins Build Agent Infrastructure
│   ├── main.tf                     # Main Terraform configuration
│   ├── variables.tf                # Input variables
│   ├── outputs.tf                  # Output values
│   ├── terraform.tfvars            # Variable values (optional customization)
│   └── README.md                   # Agent-specific notes
│
└── scripts/                        # Initialization and Setup Scripts
    ├── jenkins-controller-init.sh  # EC2 user_data for controller
    └── jenkins-agent-init.sh       # EC2 user_data for agent
```

## Quick Start

### 1. Prerequisites
- AWS Account with appropriate permissions
- Terraform v1.0+
- AWS CLI configured
- SSH key pair in AWS
- Your IP address in CIDR notation (e.g., `203.0.113.42/32`)

### 2. Update Configuration
```bash
cd controller
# Edit terraform.tfvars and update:
# - my_ip = "YOUR.IP.ADDRESS/32"
# - aws_region (if different from us-east-1)
```

### 3. Deploy Infrastructure
```bash
# Deploy controller
cd controller
terraform init
terraform plan
terraform apply

# After controller starts (~10 minutes), deploy agent
cd ../agent
terraform init
terraform plan
terraform apply
```

### 4. Complete Setup
Follow the detailed instructions in [setup.md](./setup.md):
- Access Jenkins UI
- Complete setup wizard
- Install required plugins
- Create credentials
- Configure build agent
- Test with sanity-check pipeline

## Key Components

### Jenkins Controller
- **Location**: Public subnet in VPC
- **Instance Type**: t3.medium (adjustable)
- **Port 8080**: Restricted to your IP only
- **Port 22 (SSH)**: Restricted to your IP only
- **IAM Role**: Full AWS permissions for Terraform, ECR, and other services
- **Security**: 
  - Isolated in security group
  - Only accessible from your IP
  - SSH key-based authentication
  - Encrypted EBS volumes

### Jenkins Build Agent
- **Location**: Private subnet in VPC
- **Instance Type**: t3.medium (adjustable)
- **SSH Access**: From VPC only
- **Communication**: Via SSH/JNLP with controller
- **Label**: `linux-agent`
- **Work Directory**: `/home/jenkins/agent`
- **Installed Tools**:
  - Java 17
  - Git
  - Docker
  - AWS CLI v2
  - Terraform
- **Permissions**: Full AWS access via IAM role

## Required Plugins

The `plugins.txt` file lists all required plugins. The setup process will install:

**Core Plugins**:
- Pipeline (for declarative pipelines)
- Git (for version control)
- GitHub Branch Source (for GitHub integration)
- Docker Pipeline (for container builds)
- Credentials Binding (for secure secrets)

**Recommended Plugins**:
- Blue Ocean (modern UI)
- SonarQube Scanner (code quality)
- AWS CodePipeline (AWS integration)
- Slack (notifications)
- And many more...

See `plugins.txt` for complete list and installation instructions.

## Infrastructure as Code

### Terraform Files

All infrastructure is defined as Terraform code:

**Controller** (`controller/main.tf`):
- VPC and subnet discovery
- Security group with restricted access
- EC2 instance with IAM role
- Elastic IP
- CloudWatch logging
- User data script execution

**Agent** (`agent/main.tf`):
- Same pattern as controller
- Deployed in private subnet
- SSH access from VPC
- Connected to controller via SSH

### User Data Scripts

Both instances run user_data scripts during boot:

**Controller** (`scripts/jenkins-controller-init.sh`):
- Updates system packages
- Installs Java 17
- Installs Git, Docker, AWS CLI, Terraform
- Installs Jenkins LTS
- Starts Jenkins service
- Outputs initial admin password

**Agent** (`scripts/jenkins-agent-init.sh`):
- Updates system packages
- Installs Java 17
- Installs Git, Docker, AWS CLI, Terraform
- Creates jenkins user with SSH access
- Sets up work directory
- Prepares for SSH connection to controller

## Security Considerations

1. **Network Security**
   - Controller in public subnet with restricted access
   - Agent in private subnet with no direct internet access
   - Security groups restrict traffic to what's needed

2. **Authentication**
   - SSH key-based for controller access
   - SSH JNLP for agent communication
   - Jenkins credentials for all integrations

3. **Data Protection**
   - Encrypted EBS volumes
   - Jenkins home directory permissions
   - No secrets in code or logs

4. **Access Control**
   - Your IP only for Jenkins UI and SSH
   - IAM roles instead of long-term keys
   - Jenkins credentials management

## Customization

### Change Instance Type
Edit `terraform.tfvars`:
```terraform
instance_type = "t3.large"  # For larger workloads
```

### Adjust Volume Size
Edit `terraform.tfvars`:
```terraform
root_volume_size = 100  # Increase from default 50GB
```

### Add More Agents
Copy `agent/` directory, rename, and update Terraform configuration for new agents.

### Modify Allowed IPs
Edit security group rules in `main.tf` to allow additional IPs or CIDR blocks.

## Troubleshooting

### Jenkins Slow to Start
- Give it 5-10 minutes after Terraform apply
- Check EC2 logs: `sudo tail -f /var/log/jenkins/jenkins.log`
- Plugins may be downloading during startup

### Agent Won't Connect
- Verify SSH keys are exchanged correctly
- Check agent is online: **Manage Jenkins → Manage Nodes**
- View agent logs for connection errors
- Verify security group allows port 22 from controller

### Can't Access Jenkins UI
- Verify your IP is in `my_ip` variable
- Check security group rules: `terraform output`
- Verify Jenkins is running: `sudo systemctl status jenkins`

### Terraform Apply Fails
- Ensure VPC from Assignment 3 exists
- Check AWS credentials are configured
- Verify AWS region has capacity and availability zones

## Cleanup

To destroy all resources:
```bash
cd controller
terraform destroy

cd ../agent
terraform destroy
```

**Warning**: This permanently deletes all EC2 instances and data.

## Files Not Included

The following must be created/obtained separately:
- `jenkins-key.pem` - SSH key pair (created in AWS Console)
- GitHub Personal Access Token
- AWS Access Key and Secret Key
- SonarQube token (for later tasks)
- Slack webhook URL (for notifications)

These are managed as Jenkins credentials, not in Terraform.

## Related Assignment 3 Infrastructure

This Jenkins setup builds on Assignment 3:
- **VPC**: Uses existing VPC from task1-vpc (10.0.0.0/16)
- **Subnets**: Public subnets for controller, private subnets for agent
- **IAM**: Uses IAM roles created in task3
- **Networking**: Leverages NAT Gateway for agent internet access

## Next Steps

After Jenkins is fully operational:
1. **Task 2**: Create Groovy shared libraries
2. **Task 3**: Set up SonarQube integration
3. **Task 3**: Configure Docker/ECR integration
4. **Task 4**: Implement Blue-Green deployment
5. **Task 5**: Set up Prometheus/Grafana monitoring

## Support and Documentation

- **Jenkins Official**: https://www.jenkins.io/doc/
- **Terraform AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Assignment Guide**: See setup.md for detailed step-by-step instructions

## Additional Resources

- Sample Jenkinsfile: (to be created in Task 2)
- Groovy Shared Libraries: (to be created in Task 2)
- Pipeline examples: (to be created in Tasks 3-5)

---

**Last Updated**: 2026-04-25
**Assignment**: 4 - Jenkins CI/CD Pipeline
**Version**: 1.0
