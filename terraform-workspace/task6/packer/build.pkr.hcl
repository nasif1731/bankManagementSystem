# Packer HCL2 Template for building custom Ubuntu AMI with Nginx

packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  # Use Ubuntu 22.04 LTS as base
  ami_description = "Task 6 - Custom AMI with Nginx and curl (Built with Packer)"
  ami_name        = "task6-custom-ami-${local.timestamp}"
  instance_type   = "t3.micro"
  region          = "us-east-1"

  # Find latest Ubuntu 22.04 LTS AMI
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]  # Canonical
  }

  # SSH connection settings
  ssh_username = "ubuntu"
  
  # Add descriptive tags to the AMI
  tags = {
    Name           = "task6-custom-ami"
    Environment    = "development"
    Task           = "Task6-Packer"
    CreatedBy      = "Packer"
    BuildDate      = timestamp()
    CustomContent  = "nginx+curl+welcome-page"
  }

  # Tag snapshot as well
  snapshot_tags = {
    Name        = "task6-custom-ami-snapshot"
    Environment = "development"
    Task        = "Task6-Packer"
  }

  # EBS optimization
  ebs_optimized = false
  
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  # IMDSv2 only
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Ensure public IP for SSH access during build
  associate_public_ip_address = true
}

# Build block defines how the AMI is built
build {
  name = "task6-custom-ami"
  
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  # Wait for cloud-init to complete
  provisioner "shell" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait",
      "echo 'Cloud-init completed'"
    ]
  }

  # Update system packages
  provisioner "shell" {
    inline = [
      "echo 'Updating system packages...'",
      "sudo apt-get update",
      "sudo apt-get upgrade -y"
    ]
  }

  # Install Nginx
  provisioner "shell" {
    inline = [
      "echo 'Installing Nginx...'",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "nginx -v"
    ]
  }

  # Install curl
  provisioner "shell" {
    inline = [
      "echo 'Installing curl...'",
      "sudo apt-get install -y curl",
      "curl --version"
    ]
  }

  # Create custom welcome page
  provisioner "shell" {
    inline = [
      "echo 'Creating custom welcome page...'",
      "sudo tee /var/www/html/index.html > /dev/null <<'EOF'\n<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n    <meta charset=\"UTF-8\">\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n    <title>Task 6 - Custom Packer AMI</title>\n    <style>\n        * {\n            margin: 0;\n            padding: 0;\n            box-sizing: border-box;\n        }\n        body {\n            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;\n            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);\n            min-height: 100vh;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n        }\n        .container {\n            background: white;\n            border-radius: 12px;\n            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);\n            padding: 60px 40px;\n            max-width: 600px;\n            text-align: center;\n        }\n        h1 {\n            color: #333;\n            margin-bottom: 15px;\n            font-size: 2.5em;\n        }\n        .subtitle {\n            color: #667eea;\n            font-size: 1.3em;\n            margin-bottom: 30px;\n            font-weight: 600;\n        }\n        .content {\n            color: #555;\n            line-height: 1.8;\n            margin-bottom: 30px;\n        }\n        .info {\n            background: #f8f9ff;\n            border-left: 4px solid #667eea;\n            padding: 20px;\n            margin: 20px 0;\n            text-align: left;\n            border-radius: 4px;\n        }\n        .info p {\n            margin: 8px 0;\n            color: #666;\n            font-family: 'Monaco', 'Courier New', monospace;\n            font-size: 0.9em;\n        }\n        .features {\n            display: grid;\n            grid-template-columns: 1fr 1fr;\n            gap: 15px;\n            margin: 30px 0;\n            text-align: left;\n        }\n        .feature {\n            padding: 15px;\n            background: #f8f9ff;\n            border-radius: 8px;\n            border-left: 3px solid #764ba2;\n        }\n        .feature-title {\n            color: #764ba2;\n            font-weight: 600;\n            margin-bottom: 5px;\n        }\n        .feature-desc {\n            color: #777;\n            font-size: 0.9em;\n        }\n        .footer {\n            color: #999;\n            font-size: 0.9em;\n            border-top: 1px solid #eee;\n            padding-top: 20px;\n            margin-top: 30px;\n        }\n        .badge {\n            display: inline-block;\n            background: #667eea;\n            color: white;\n            padding: 4px 12px;\n            border-radius: 20px;\n            font-size: 0.8em;\n            margin: 5px;\n            font-weight: 600;\n        }\n    </style>\n</head>\n<body>\n    <div class=\"container\">\n        <h1>🎉 Welcome!</h1>\n        <p class=\"subtitle\">Task 6 - Custom Packer AMI</p>\n        \n        <div class=\"content\">\n            <p>This is a custom Amazon Machine Image (AMI) created with <strong>Packer</strong>.</p>\n            <p>It demonstrates infrastructure automation and code reusability with Terraform modules.</p>\n        </div>\n\n        <div class=\"info\">\n            <p><strong>✓ Nginx:</strong> Web server installed and running</p>\n            <p><strong>✓ curl:</strong> Command-line HTTP client available</p>\n            <p><strong>✓ Ubuntu 22.04 LTS:</strong> Base operating system</p>\n        </div>\n\n        <div class=\"features\">\n            <div class=\"feature\">\n                <div class=\"feature-title\">🔧 Modular Infrastructure</div>\n                <div class=\"feature-desc\">Built with reusable Terraform modules</div>\n            </div>\n            <div class=\"feature\">\n                <div class=\"feature-title\">📦 Automated Images</div>\n                <div class=\"feature-desc\">Created using Packer HCL templates</div>\n            </div>\n            <div class=\"feature\">\n                <div class=\"feature-title\">🚀 Production Ready</div>\n                <div class=\"feature-desc\">Optimized and fully configured</div>\n            </div>\n            <div class=\"feature\">\n                <div class=\"feature-title\">🔐 Security First</div>\n                <div class=\"feature-desc\">IMDSv2 and encrypted storage</div>\n            </div>\n        </div>\n\n        <div style=\"text-align: center; margin: 25px 0;\">\n            <span class=\"badge\">Packer</span>\n            <span class=\"badge\">Terraform</span>\n            <span class=\"badge\">Nginx</span>\n            <span class=\"badge\">Ubuntu</span>\n            <span class=\"badge\">AWS</span>\n        </div>\n\n        <div class=\"footer\">\n            <p>This page is served by Nginx running on this custom AMI instance.</p>\n            <p>Built with ❤️ using Packer and Terraform</p>\n        </div>\n    </div>\n</body>\n</html>\nEOF"
    ]
  }

  # Verify Nginx and curl installation
  provisioner "shell" {
    inline = [
      "echo 'Verifying installations...'",
      "which nginx && echo 'Nginx: OK'",
      "which curl && echo 'curl: OK'",
      "systemctl is-enabled nginx && echo 'Nginx autostart: OK'",
      "curl -I http://localhost/ | head -3"
    ]
  }

  # Clean up (optional)
  provisioner "shell" {
    inline = [
      "echo 'Cleaning up...'",
      "sudo apt-get clean",
      "sudo apt-get autoclean",
      "echo 'Build completed successfully!'"
    ]
  }
}
