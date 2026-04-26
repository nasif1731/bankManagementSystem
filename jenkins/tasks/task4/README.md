# Task 4: Blue-Green Deployment

## Overview

Task 4 implements Blue-Green deployment strategy for zero-downtime updates.

## What is Blue-Green Deployment?

```
Current State (Blue):
├─ Blue Environment (Production)
│  └─ Running version 1.0
│     ├─ Load Balancer → Blue
│     └─ Users getting served

Deployment (Green):
├─ Green Environment (Staging)
│  └─ Running version 2.0 (new)
│     ├─ No users yet
│     └─ Testing complete

Switch:
├─ Blue Environment ← DISABLED
│  └─ version 1.0 stops receiving traffic
│
├─ Green Environment ← ENABLED
│  └─ version 2.0 now receiving all traffic
│     ├─ Load Balancer → Green
│     └─ Users see new version
│
Quick Rollback:
├─ If problems: Switch back to Blue instantly
└─ Zero downtime, instant rollback
```

## What You'll Do

1. **Create two environments** (Blue and Green)
2. **Deploy new version to inactive environment**
3. **Run integration tests** on new environment
4. **Switch load balancer** to new environment
5. **Monitor for issues** after switch
6. **Enable instant rollback** if problems detected

## Pipeline Flow

```
1. Checkout & Build
   ↓
2. Deploy to GREEN (inactive)
   ↓
3. Run Health Checks on GREEN
   ↓
4. Run Integration Tests on GREEN
   ↓
5. Switch Load Balancer: BLUE → GREEN
   ↓
6. Monitor GREEN in production
   ↓
7. Keep BLUE as rollback target
```

## Key Concepts

- **Blue**: Current production environment
- **Green**: New staging environment (where new version deploys)
- **Load Balancer**: Routes traffic between Blue and Green
- **Health Checks**: Verify new version is healthy before switching
- **Instant Rollback**: Switch back to Blue if issues detected

## Terraform Deployment

Use Terraform modules to create:
- Two EC2 instances (Blue and Green)
- Load balancer configuration
- Health checks
- Auto-scaling groups (optional)
- Target groups for traffic routing

## Files to Create

```
jenkins/tasks/task4/
├── Jenkinsfile                    # Blue-Green pipeline
├── README.md                       # This file
├── deployment/
│   ├── blue-deployment.yaml       # Blue environment config
│   ├── green-deployment.yaml      # Green environment config
│   └── load-balancer.tf           # Terraform for LB
└── health-checks.sh               # Health check script
```

## Status

- [ ] Blue environment deployed
- [ ] Green environment deployed
- [ ] Load balancer configured
- [ ] Health check script working
- [ ] Jenkinsfile implements Blue-Green logic
- [ ] Can deploy to Green without affecting Blue
- [ ] Can switch traffic from Blue to Green
- [ ] Can instantly rollback to Blue

---

**Next Task**: Task 5 - Monitoring with Prometheus & Grafana
