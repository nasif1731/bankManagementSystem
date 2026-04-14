# Task 4: Auto Scaling Group with CloudWatch Alarms

This Terraform configuration sets up an Auto Scaling Group (ASG) with CloudWatch monitoring to automatically scale EC2 instances based on CPU utilization. Includes stress testing tools and comprehensive monitoring.

## Architecture Overview

```
┌───────────────────────────────────────────────────────┐
│           Task 4: Auto Scaling Infrastructure          │
├───────────────────────────────────────────────────────┤
│                                                        │
│  Task 2 VPC (10.1.0.0/16)                             │
│  ├─ Public Subnet AZ-1 (10.1.1.0/24)                  │
│  │  └─ ASG Instance (Min 1, Max 3, Desired 1)        │
│  ├─ Public Subnet AZ-2 (conditionally)                │
│  └─ Web Security Group (HTTP, HTTPS, SSH)            │
│                                                        │
│  Launch Template:                                      │
│  ├─ AMI: Amazon Linux 2                               │
│  ├─ Instance Type: t3.micro                           │
│  ├─ Key Pair: From Task 2                             │
│  ├─ User Data: stress-ng installation                │
│  └─ Monitoring: Enabled                               │
│                                                        │
│  CloudWatch Alarms:                                    │
│  ├─ High CPU (≥60%) → Scale Out (+1 instance)        │
│  ├─ Low CPU (≤20%) → Scale In (-1 instance)          │
│  └─ 2 consecutive 60-sec periods to trigger          │
│                                                        │
│  Auto Scaling Policies:                               │
│  ├─ Scale Out: +1 instance, 120s cooldown            │
│  └─ Scale In: -1 instance, 120s cooldown             │
│                                                        │
└───────────────────────────────────────────────────────┘
```

## Resources Created

| Resource | Type | Purpose |
|----------|------|---------|
| `aws_launch_template.web` | Launch Template | EC2 instance template with stress-ng |
| `aws_autoscaling_group.web` | ASG | Auto Scaling Group (min 1, max 3) |
| `aws_autoscaling_policy.scale_out` | ASG Policy | Add instance on high CPU |
| `aws_autoscaling_policy.scale_in` | ASG Policy | Remove instance on low CPU |
| `aws_cloudwatch_metric_alarm.cpu_high` | CloudWatch Alarm | High CPU alarm (≥60%) |
| `aws_cloudwatch_metric_alarm.cpu_low` | CloudWatch Alarm | Low CPU alarm (≤20%) |
| Data Sources | Referenced | Task 2 VPC, subnets, security groups, key pair |

## Key Features

✓ **Launch Template**
- Amazon Linux 2 AMI (latest)
- t3.micro instance type
- SSH key pair from Task 2
- Web security group from Task 2
- Detailed monitoring enabled
- stress-ng pre-installed for load testing
- IMDSv2 enabled for security
- EBS GP3 encryption-ready

✓ **Auto Scaling Group**
- Spans across public subnets from Task 2
- Min: 1, Max: 3, Desired: 1 instance
- Name tag propagates to all launched instances
- 5-minute grace period for health checks
- 5-minute default cooldown

✓ **Scaling Policies**
- Scale-out: ChangeInCapacity, +1 instance, 120s cooldown
- Scale-in: ChangeInCapacity, -1 instance, 120s cooldown
- Prevents rapid oscillation with cooldown periods

✓ **CloudWatch Monitoring**
- High CPU alarm: ≥60% for 2 periods of 60 seconds
- Low CPU alarm: ≤20% for 2 periods of 60 seconds
- Triggers scaling policies automatically
- Detailed metrics every 60 seconds

✓ **Stress Testing Tools**
- stress-ng installed on all instances for CPU load generation
- Can generate sustained high CPU utilization

## Variables

- `aws_region` - AWS region (default: us-east-1)
- `instance_type` - EC2 instance type (default: t3.micro)
- `asg_min_size` - Minimum ASG size (default: 1)
- `asg_max_size` - Maximum ASG size (default: 3)
- `asg_desired_capacity` - Desired instance count (default: 1)
- `cpu_scale_out_threshold` - High CPU threshold (default: 60%)
- `cpu_scale_in_threshold` - Low CPU threshold (default: 20%)
- `cloudwatch_evaluation_periods` - Consecutive periods (default: 2)
- `cloudwatch_period` - Period duration in seconds (default: 60)

## Outputs

- `launch_template_id` - Launch template ID
- `autoscaling_group_name` - ASG name
- `cpu_high_alarm` - High CPU alarm ARN
- `cpu_low_alarm` - Low CPU alarm ARN
- `stress_ng_command` - Command to run stress test
- `view_asg_activity_command` - Command to view scaling events
- `public_subnets` - Subnets where ASG launches instances
- `security_group_id` - Security group for instances

## How to Run

### 1. Deploy Task 2 First
Task 4 depends on Task 2's VPC and security group. Ensure Task 2 is deployed.

```bash
cd ../task2
terraform apply -auto-approve
cd ../task4
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Validate Configuration
```bash
terraform validate
```

### 4. Apply Configuration
```bash
terraform plan -out=task4.tfplan
terraform apply task4.tfplan
# or for auto-approval:
terraform apply -auto-approve
```

### 5. View Outputs
```bash
terraform output
```

## Testing Auto Scaling

### Step 1: SSH into Running Instance
```bash
# Get instance IP from EC2 console or:
aws ec2 describe-instances --filters "Name=tag:Name,Values=task4-asg-instance" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text

# SSH in
ssh -i /path/to/key.pem ec2-user@<instance-ip>
```

### Step 2: Generate CPU Load with stress-ng
```bash
# Start stress-ng to generate 100% CPU load on 1 core for 5 minutes (300 seconds)
stress-ng --cpu 1 --cpu-load 100 --timeout 300s

# In another terminal, monitor CPU:
top -b | head -20
```

### Step 3: Monitor ASG Activity
```bash
# Watch ASG activity in real-time (requires jq)
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name <asg-name> \
  --query 'Activities[*].[StartTime,Description,StatusCode]' \
  --output table

# Or watch CloudWatch alarms
aws cloudwatch describe-alarms --alarm-names task4-cpu-high-alarm --output table
```

### Step 4: Monitor Metrics
```bash
# View CPU utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=AutoScalingGroupName,Value=<asg-name> \
  --start-time $(date -u -d '15 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Average
```

### Step 5: Stop Stress Test
```bash
# Ctrl+C on the stress-ng command
# Then watch as instances scale back down
```

## Expected Behavior

**When stress-ng starts:**
1. CPU utilization rises above 60%
2. CloudWatch alarm `task4-cpu-high-alarm` enters ALARM state
3. After 2 periods (120 seconds), scale-out policy triggers
4. New instance launches (ASG goes 1 → 2)
5. After stopping stress, CPU drops below 20%
6. CloudWatch alarm `task4-cpu-low-alarm` enters ALARM state
7. After 2 periods, scale-in policy triggers
8. Instance terminates (ASG goes 2 → 1)

**Timeline:**
- T+0s: stress-ng starts, CPU rises
- T+60s: First high CPU metric observed (evaluation period 1)
- T+120s: Second high CPU metric observed (evaluation period 2), alarm fires
- T+120-180s: New instance launching (depends on boot time)
- T+300s: stress-ng stops, CPU normalizes
- T+360-420s: Low CPU detected for 2 periods
- T+420-480s: Instance terminating

## Troubleshooting

**Alarms not triggering:**
- Verify instances have detailed monitoring enabled (check launch template)
- Check CloudWatch metrics for the ASG
- Ensure stress-ng is running (`top` or `ps` should show it)
- Check CPU metrics haven't filtered incorrectly

**Instances not launching:**
- Verify ASG can access data sources (Task 2 VPC/SG)
- Check AWS IAM permissions for CloudWatch and ASG
- Review ASG activity history for errors

**stress-ng not working:**
- SSH into instance and check: `stress-ng --version`
- Verify user data script ran: `tail -f /var/log/user-data.log`
- Try manual installation: `sudo amazon-linux-extras install -y stress-ng`

## Cleanup

To destroy all Task 4 resources:
```bash
terraform destroy -auto-approve
```

⚠️ **Note**: This will terminate all ASG instances. Ensure stress test is stopped first.

## Deliverables

1. **ASG in AWS Console**
   - ASG name and capacity
   - Running instances
   - Configuration details

2. **CloudWatch Alarms**
   - High CPU alarm in ALARM state
   - Low CPU alarm state
   - Alarm history

3. **Scaling Events**
   - ASG Activity History showing:
     - Instance launch events
     - Instance termination events
     - Timestamps and status

4. **Terminal Screenshots**
   - stress-ng command running
   - CPU load visible in `top`
   - ASG activity history output
   - CloudWatch metrics

## References

- [AWS AutoScaling Documentation](https://docs.aws.amazon.com/autoscaling/)
- [stress-ng Manual](https://wiki.ubuntu.com/stress-ng)
- `.gitignore` - Git ignore patterns

## Status
⏳ Awaiting task requirements

Once the task is assigned, files will be created following the same pattern as Task 1 and Task 2.
