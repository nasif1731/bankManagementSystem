#!/bin/bash
# Helper script to manage Jenkins infrastructure
# Provides utilities for deploying, monitoring, and troubleshooting

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check Terraform
    if command -v terraform &> /dev/null; then
        TERRAFORM_VERSION=$(terraform version -json 2>/dev/null | grep -o '"terraform_version": "[^"]*"' | cut -d'"' -f4)
        print_success "Terraform found: v$TERRAFORM_VERSION"
    else
        print_error "Terraform not found. Please install Terraform first."
        exit 1
    fi
    
    # Check AWS CLI
    if command -v aws &> /dev/null; then
        AWS_VERSION=$(aws --version 2>&1 | awk '{print $1}')
        print_success "AWS CLI found: $AWS_VERSION"
    else
        print_error "AWS CLI not found. Please install AWS CLI first."
        exit 1
    fi
    
    # Check AWS credentials
    if aws sts get-caller-identity &> /dev/null; then
        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        print_success "AWS credentials configured (Account: $ACCOUNT_ID)"
    else
        print_error "AWS credentials not configured. Please run 'aws configure'."
        exit 1
    fi
    
    echo ""
}

# Deploy controller
deploy_controller() {
    print_header "Deploying Jenkins Controller"
    
    cd controller
    
    # Check tfvars customization
    if grep -q "0.0.0.0/32" terraform.tfvars; then
        print_warning "terraform.tfvars still has default my_ip value (0.0.0.0/32)"
        print_info "Please update my_ip in terraform.tfvars to your actual IP address"
        echo -n "Continue anyway? (y/n): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_error "Deployment cancelled"
            cd ..
            return 1
        fi
    fi
    
    print_info "Initializing Terraform..."
    terraform init
    
    print_info "Running plan..."
    terraform plan -out=tfplan
    
    echo ""
    print_info "Ready to apply. Review the plan above."
    echo -n "Continue with terraform apply? (y/n): "
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_error "Deployment cancelled"
        rm tfplan
        cd ..
        return 1
    fi
    
    print_info "Applying configuration..."
    terraform apply tfplan
    rm tfplan
    
    print_header "Controller Deployment Complete"
    print_info "Displaying outputs..."
    terraform output
    
    cd ..
    print_success "Jenkins controller deployed successfully"
    echo ""
}

# Deploy agent
deploy_agent() {
    print_header "Deploying Jenkins Build Agent"
    
    cd agent
    
    print_info "Initializing Terraform..."
    terraform init
    
    print_info "Running plan..."
    terraform plan -out=tfplan
    
    echo ""
    print_info "Ready to apply. Review the plan above."
    echo -n "Continue with terraform apply? (y/n): "
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_error "Deployment cancelled"
        rm tfplan
        cd ..
        return 1
    fi
    
    print_info "Applying configuration..."
    terraform apply tfplan
    rm tfplan
    
    print_header "Agent Deployment Complete"
    print_info "Displaying outputs..."
    terraform output
    
    cd ..
    print_success "Jenkins build agent deployed successfully"
    echo ""
}

# Show deployment info
show_info() {
    print_header "Deployment Information"
    
    echo -e "${BLUE}Controller Information:${NC}"
    cd controller
    if [ -f terraform.tfstate ]; then
        echo "Instance ID: $(terraform output -raw jenkins_controller_instance_id 2>/dev/null || echo 'N/A')"
        echo "Public IP: $(terraform output -raw jenkins_controller_public_ip 2>/dev/null || echo 'N/A')"
        echo "Jenkins URL: $(terraform output -raw jenkins_url 2>/dev/null || echo 'N/A')"
        echo "SSH Command: $(terraform output -raw ssh_command 2>/dev/null || echo 'N/A')"
    else
        print_warning "Controller not deployed yet"
    fi
    cd ..
    
    echo ""
    echo -e "${BLUE}Agent Information:${NC}"
    cd agent
    if [ -f terraform.tfstate ]; then
        echo "Instance ID: $(terraform output -raw jenkins_agent_instance_id 2>/dev/null || echo 'N/A')"
        echo "Private IP: $(terraform output -raw jenkins_agent_private_ip 2>/dev/null || echo 'N/A')"
        echo "Work Directory: $(terraform output -raw jenkins_agent_work_dir 2>/dev/null || echo 'N/A')"
        echo "Label: $(terraform output -raw jenkins_agent_label 2>/dev/null || echo 'N/A')"
    else
        print_warning "Agent not deployed yet"
    fi
    cd ..
    
    echo ""
}

# Destroy infrastructure
destroy_infrastructure() {
    print_header "Destroying Jenkins Infrastructure"
    
    print_warning "This will terminate all EC2 instances and delete Jenkins data!"
    echo -n "Are you sure? Type 'yes' to confirm: "
    read -r response
    
    if [ "$response" != "yes" ]; then
        print_info "Destruction cancelled"
        return
    fi
    
    print_info "Destroying agent..."
    cd agent
    terraform destroy -auto-approve
    cd ..
    
    print_info "Destroying controller..."
    cd controller
    terraform destroy -auto-approve
    cd ..
    
    print_success "Infrastructure destroyed"
}

# Show help
show_help() {
    cat << EOF
Jenkins Infrastructure Management Script

Usage: $0 <command>

Commands:
    check           Check prerequisites (Terraform, AWS CLI, credentials)
    deploy-all      Deploy both controller and agent
    deploy-ctrl     Deploy only Jenkins controller
    deploy-agent    Deploy only Jenkins build agent
    info            Show deployment information and outputs
    destroy         Destroy all infrastructure (WARNING: Data loss!)
    help            Show this help message

Examples:
    $0 check                # Verify everything is ready
    $0 deploy-all           # Deploy full infrastructure
    $0 info                 # Show current deployment status
    $0 destroy              # Clean up all resources

Prerequisites:
    - Terraform >= 1.0
    - AWS CLI configured with credentials
    - SSH key pair created in AWS
    - Your IP address ready for security group configuration

For detailed setup instructions, see: setup.md
EOF
}

# Main script logic
case "${1:-help}" in
    check)
        check_prerequisites
        ;;
    deploy-all)
        check_prerequisites
        deploy_controller && deploy_agent && show_info
        ;;
    deploy-ctrl)
        check_prerequisites
        deploy_controller && show_info
        ;;
    deploy-agent)
        check_prerequisites
        deploy_agent && show_info
        ;;
    info)
        show_info
        ;;
    destroy)
        destroy_infrastructure
        ;;
    help|*)
        show_help
        ;;
esac
