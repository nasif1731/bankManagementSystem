# Task 5: Monitoring with Prometheus and Grafana

## Overview

Task 5 sets up monitoring infrastructure to track Jenkins pipeline metrics and application performance.

## What You'll Do

1. **Deploy Prometheus** to collect metrics
2. **Deploy Grafana** for visualization
3. **Create dashboards** for pipeline metrics
4. **Set up alerts** for failures and performance issues
5. **Monitor Jenkins** performance
6. **Monitor applications** running on EC2

## Architecture

```
Applications & Jenkins
        ↓
    Exporters
    (collect metrics)
        ↓
   Prometheus
   (scrape & store)
        ↓
   Grafana
   (visualize)
        ↓
      Users
    (dashboards)
        ↓
     Alerts
  (PagerDuty, Slack, etc.)
```

## Key Components

### Prometheus
- Time-series database
- Scrapes metrics from exporters
- Stores metrics locally
- Query language: PromQL

### Grafana
- Visualization tool
- Connects to Prometheus as datasource
- Creates dashboards
- Sends alerts on metric thresholds

### Exporters
- Jenkins exporter (metrics about jobs, builds)
- Node exporter (CPU, memory, disk of EC2 instances)
- Docker exporter (container metrics)

## Files to Create

```
jenkins/tasks/task5/
├── Jenkinsfile                   # Pipeline for monitoring setup
├── README.md                      # This file
└── monitoring/
    ├── prometheus.yml             # Prometheus config
    ├── grafana-datasource.json    # Grafana data source
    ├── dashboards/
    │   ├── jenkins-dashboard.json
    │   ├── application-dashboard.json
    │   └── infrastructure-dashboard.json
    └── alerts.yaml               # Alert rules
```

## Dashboards to Create

### 1. Jenkins Pipeline Metrics
- Total builds per day
- Build success/failure rate
- Average build duration
- Build queue depth
- Agent utilization

### 2. Application Metrics
- Request rate (requests/sec)
- Response time (latency)
- Error rate
- Throughput
- Uptime percentage

### 3. Infrastructure Metrics
- CPU usage per instance
- Memory usage per instance
- Disk I/O
- Network I/O
- EC2 instance count

## Alert Rules

Create alerts for:
- Build failures
- Build timeout (> 30 minutes)
- High CPU usage (> 80%)
- High memory usage (> 90%)
- Disk space critical (< 10%)
- Application errors spike
- Agent offline

## Deployment Options

### Option 1: Docker Compose
Deploy all in containers on single instance

### Option 2: Kubernetes
Deploy on EKS/Kubernetes cluster

### Option 3: EC2 Instances
Deploy Prometheus and Grafana on separate instances

## Status

- [ ] Prometheus deployed and scraping metrics
- [ ] Grafana deployed and connected to Prometheus
- [ ] Jenkins exporter running
- [ ] Node exporters installed on all EC2 instances
- [ ] At least 3 dashboards created
- [ ] Alerts configured
- [ ] Slack notifications working (optional)
- [ ] Screenshots of dashboards

## Integration with Jenkins

### Jenkins Plugin
Install Prometheus plugin:
- Go to Manage Jenkins → Manage Plugins
- Search for "Prometheus Metrics"
- Install and restart

Jenkins then exposes metrics at:
```
http://jenkins-controller:8080/prometheus/
```

### Configure Prometheus Scrape Job
```yaml
scrape_configs:
  - job_name: 'jenkins'
    static_configs:
      - targets: ['jenkins-controller:8080']
    metrics_path: '/prometheus/'
```

---

**Task 5 Complete**: Full monitoring infrastructure in place!

---

## Summary: All Tasks Completed

After all 5 tasks:
- ✅ Jenkins infrastructure deployed
- ✅ Reusable Groovy shared libraries
- ✅ Code quality scanning with SonarQube
- ✅ Docker builds and ECR integration
- ✅ Blue-Green deployment pipeline
- ✅ Monitoring with Prometheus & Grafana

**You've built a production-grade CI/CD platform!**
