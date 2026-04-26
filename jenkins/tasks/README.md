# Jenkins CI/CD Tasks - Complete Guide

This folder contains organized Jenkinsfiles and resources for all 5 tasks of the Jenkins assignment.

## 📋 Quick Navigation

| Task | Focus | Status | Jenkinsfile |
|------|-------|--------|------------|
| **Task 1** | Sanity Check & Setup | Core | `task1/Jenkinsfile` |
| **Task 2** | Groovy Shared Libraries | Advanced | `task2/Jenkinsfile` |
| **Task 3** | SonarQube + Docker ECR | Integration | `task3/Jenkinsfile` |
| **Task 4** | Blue-Green Deployment | Production | `task4/Jenkinsfile` |
| **Task 5** | Monitoring (Prometheus + Grafana) | Operations | `task5/Jenkinsfile` |

---

## 📁 Directory Structure

```
tasks/
├── task1/
│   ├── Jenkinsfile              # Sanity-check pipeline (8 stages)
│   └── README.md                # Task 1 documentation
│
├── task2/
│   ├── Jenkinsfile              # Pipeline using shared libraries
│   ├── README.md                # Task 2 documentation
│   └── vars/                    # Groovy shared library functions
│       ├── checkoutCode.groovy
│       ├── buildArtifact.groovy
│       ├── runTests.groovy
│       └── (add more functions)
│
├── task3/
│   ├── Jenkinsfile              # SonarQube + Docker pipeline
│   ├── README.md                # Task 3 documentation
│   ├── Dockerfile               # Docker image definition
│   └── sonar-project.properties # SonarQube config
│
├── task4/
│   ├── Jenkinsfile              # Blue-Green deployment pipeline
│   ├── README.md                # Task 4 documentation
│   └── deployment/
│       ├── blue-deployment.yaml
│       ├── green-deployment.yaml
│       └── load-balancer.tf
│
├── task5/
│   ├── Jenkinsfile              # Monitoring setup pipeline
│   ├── README.md                # Task 5 documentation
│   └── monitoring/
│       ├── prometheus.yml
│       ├── grafana-datasource.json
│       ├── dashboards/
│       │   ├── jenkins-dashboard.json
│       │   ├── application-dashboard.json
│       │   └── infrastructure-dashboard.json
│       └── alerts.yaml
│
└── README.md                    # This file
```

---

## 🚀 How to Use These Tasks

### Step 1: Complete Task 1 First
Task 1 is the foundation. All other tasks depend on Task 1 being working.

```bash
# Task 1: Sanity Check
# Location: jenkins/tasks/task1/Jenkinsfile
# Duration: 10 minutes
# Status: ✅ Provides working Jenkins setup
```

**Do Task 1 first before anything else!**

### Step 2: Start with Task 2
Once Task 1 is complete, move to Task 2 to implement Groovy shared libraries.

```bash
# Task 2: Groovy Shared Libraries
# Location: jenkins/tasks/task2/
# Duration: 4-6 hours
# Status: 🔄 Build reusable functions
```

### Step 3-5: Progress Through Remaining Tasks
After Task 2, continue with Tasks 3, 4, and 5 in order.

---

## 📝 For Each Task

### 1. Read the README
```bash
# Example for Task 1
cat task1/README.md
```

### 2. Create Jenkins Job
In Jenkins UI:
- New Item
- Name: Pick a name (e.g., "Task1-Sanity-Check")
- Type: Pipeline
- Copy Jenkinsfile content from file

### 3. Run the Pipeline
```bash
# Click "Build Now" in Jenkins UI
# Monitor in "Build History"
# View "Console Output"
```

### 4. Document Results
- Take screenshots
- Note any errors
- Document customizations

### 5. Move to Next Task
Only proceed to next task when current task succeeds.

---

## 🔑 Key Points for Each Task

### Task 1: Sanity Check
**Goal**: Verify Jenkins is working

**You'll do**:
- Deploy infrastructure (Terraform)
- Complete Jenkins UI setup
- Create credentials
- Configure agent
- Run sanity-check pipeline

**Success Criteria**:
- Pipeline runs on agent (not controller)
- All 8 stages complete successfully
- Shows all tool versions
- Takes ~2-3 minutes

---

### Task 2: Groovy Shared Libraries
**Goal**: Create reusable pipeline code

**You'll do**:
- Create Groovy functions in `vars/` directory
- Implement at least 3-5 functions
- Create Jenkinsfile that uses library
- Store library in Git repository
- Register library in Jenkins

**Success Criteria**:
- Library functions are callable from pipeline
- Pipeline uses @Library annotation
- At least 3 working functions
- Can be reused across multiple jobs

**Important**: Write your OWN code, don't copy!

---

### Task 3: SonarQube + Docker
**Goal**: Add code quality and containerization

**You'll do**:
- Integrate SonarQube scanner
- Build Docker images
- Push to AWS ECR
- Create Dockerfile
- Implement quality gates

**Success Criteria**:
- SonarQube scans code
- Docker image builds successfully
- Image pushed to ECR
- Pipeline shows code metrics
- Images versioned by build number

---

### Task 4: Blue-Green Deployment
**Goal**: Implement zero-downtime deployments

**You'll do**:
- Create Blue environment (current production)
- Create Green environment (staging)
- Deploy to Green without affecting Blue
- Switch load balancer to Green
- Implement instant rollback to Blue

**Success Criteria**:
- Two environments deployed
- Can deploy to Green independently
- Load balancer switches traffic
- Can rollback instantly
- No downtime during switch

---

### Task 5: Monitoring
**Goal**: Monitor infrastructure and pipelines

**You'll do**:
- Deploy Prometheus
- Deploy Grafana
- Create dashboards
- Set up alerts
- Monitor Jenkins, applications, infrastructure

**Success Criteria**:
- Prometheus collecting metrics
- Grafana dashboards displaying data
- Alerts configured
- Can visualize pipeline metrics
- Can track application health

---

## 🎯 Creating Jenkins Jobs in UI

### For Each Task Jenkinsfile

#### Method 1: Direct Pipeline Job (Recommended for Learning)
1. Jenkins Dashboard
2. Click **New Item**
3. **Name**: `Task1-Sanity-Check` (or task number)
4. **Type**: **Pipeline**
5. Click **OK**
6. **Pipeline section**:
   - Select **Pipeline script**
   - Copy entire Jenkinsfile content
   - Paste into Script box
7. **Save**
8. **Build Now**

#### Method 2: From Git Repository (Recommended for Production)
1. Jenkins Dashboard
2. Click **New Item**
3. **Name**: `Task1-From-Git`
4. **Type**: **Pipeline**
5. Click **OK**
6. **Pipeline section**:
   - Select **Pipeline script from SCM**
   - **SCM**: Git
   - **Repository URL**: Your repo
   - **Script Path**: `jenkins/tasks/task1/Jenkinsfile`
7. **Save**
8. **Build Now**

#### Method 3: Multibranch Pipeline (For Multiple Tasks)
1. Jenkins Dashboard
2. Click **New Item**
3. **Name**: `Jenkins-Tasks`
4. **Type**: **Multibranch Pipeline**
5. Click **OK**
6. **Branch Sources**:
   - Add Git
   - **Repository URL**: Your repo
7. **Scan Multibranch Pipeline Triggers**: Enable automatic scanning
8. Click **Save**

Jenkins automatically discovers Jenkinsfiles in `jenkins/tasks/task*/Jenkinsfile`

---

## 📊 Progress Tracking

Use this table to track your progress:

| Task | Status | Jenkinsfile Created | Pipeline Job Created | Executed Successfully | Screenshots | Notes |
|------|--------|-------------------|-------------------|----------------------|-----------|--------|
| 1 | ⏳ | ✅ | ⏳ | ⏳ | ⏳ | Start here! |
| 2 | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | After Task 1 |
| 3 | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | After Task 2 |
| 4 | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | After Task 3 |
| 5 | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | After Task 4 |

Legend: ⏳ = Not Started | 🔄 = In Progress | ✅ = Complete

---

## 💡 Tips for Success

### 1. **Do Tasks in Order**
   Don't skip tasks. Each builds on the previous one.

### 2. **Understand, Don't Copy**
   Read the code. Understand what each stage does.

### 3. **Test Incrementally**
   Don't create all tasks at once. Test each one.

### 4. **Document as You Go**
   Keep notes on what you learn and what works.

### 5. **Prepare for Viva**
   Be able to explain:
   - What each pipeline stage does
   - Why it's structured that way
   - How to modify and test changes
   - How to troubleshoot failures

### 6. **Ask Questions**
   If stuck on a task:
   - Read the README.md first
   - Check the Jenkinsfile comments
   - Review TROUBLESHOOTING.md in parent jenkins/ directory
   - Check Jenkins logs

---

## 🔍 Testing Each Task

### General Testing Approach

1. **Review the Jenkinsfile**
   - Read comments and understand each stage
   - Look for environment variables
   - Check credentials references

2. **Create Jenkins Job**
   - Use one of the methods above
   - Save the configuration

3. **Run First Build**
   - Click **Build Now**
   - Monitor console output
   - Note any errors

4. **Fix Issues**
   - Check TROUBLESHOOTING.md
   - Review Jenkins logs
   - Modify configuration if needed
   - Run again

5. **Verify Success**
   - Look for SUCCESS in console output
   - Check for green checkmarks
   - Verify artifacts/outputs created

6. **Document**
   - Take screenshots
   - Note what you learned
   - Document any customizations

---

## 🔗 Jenkinsfile Usage in Pipeline UI

### Creating Job from Jenkinsfile (Simple)

In Jenkins UI:
1. Create new **Pipeline** job
2. Select **Pipeline script**
3. Paste Jenkinsfile content:

```groovy
// Paste entire contents of task1/Jenkinsfile here
```

### Creating Job from Git (Better for Production)

In Jenkins UI:
1. Create new **Pipeline** job
2. Select **Pipeline script from SCM**
3. **SCM**: Git
4. **Repository URL**: https://github.com/your-user/bankManagementSystem.git
5. **Script Path**: jenkins/tasks/task1/Jenkinsfile

Jenkins automatically runs when code is pushed!

---

## 📦 Files Included

Each task has:
- **README.md** - What the task does
- **Jenkinsfile** - The pipeline code
- **Supporting files** - Task-specific configurations

### Task 1 Extras
- None (just Jenkinsfile)

### Task 2 Extras
- `vars/` - Groovy shared library functions

### Task 3 Extras
- `Dockerfile` - Docker image definition
- `sonar-project.properties` - SonarQube config

### Task 4 Extras
- `deployment/` - Blue-Green configs

### Task 5 Extras
- `monitoring/` - Prometheus, Grafana configs

---

## ⏰ Time Estimates

| Task | Duration | Difficulty | Blocker |
|------|----------|------------|---------|
| Task 1 | 2-3 hours | Easy | Foundation |
| Task 2 | 4-6 hours | Medium | Groovy knowledge |
| Task 3 | 3-4 hours | Medium | SonarQube setup |
| Task 4 | 5-6 hours | Hard | Load balancer config |
| Task 5 | 4-5 hours | Medium | Monitoring tools |
| **Total** | **18-24 hours** | **Various** | **~1 week** |

---

## ✅ Submission Checklist

For each task:
- [ ] README.md read and understood
- [ ] Jenkinsfile reviewed and understood
- [ ] Jenkins job created and saved
- [ ] Pipeline executed successfully
- [ ] No errors in console output
- [ ] Screenshots taken (per README)
- [ ] Code customized (not just copied)
- [ ] Documentation updated if modified

---

## 🆘 Need Help?

1. **For Task 1 Issues**:
   - See EXECUTION_GUIDE.md in parent jenkins/ directory
   - Check TROUBLESHOOTING.md

2. **For Task 2+ Issues**:
   - Read the task README.md
   - Check Jenkinsfile comments
   - Look at SHARED_LIBRARY_REFERENCE.md (for Task 2)

3. **For General Issues**:
   - Check https://www.jenkins.io/doc/book/pipeline/
   - Review AWS documentation
   - Check tool-specific documentation

---

## 🎓 Learning Resources

- **Jenkins Docs**: https://www.jenkins.io/doc/
- **Groovy**: https://groovy-lang.org/documentation.html
- **Docker**: https://docs.docker.com/
- **Terraform**: https://www.terraform.io/docs
- **Prometheus**: https://prometheus.io/docs/
- **Grafana**: https://grafana.com/docs/

---

## 📞 Quick Reference

### Commands to Remember

```bash
# Navigate to tasks
cd jenkins/tasks

# View task structure
tree .

# Read task README
cat task1/README.md

# View Jenkinsfile
cat task1/Jenkinsfile

# Create new task folder (example)
mkdir -p task2/vars
```

### Jenkins Shortcuts

- Dashboard: http://jenkins-ip:8080/
- Credentials: http://jenkins-ip:8080/credentials/
- Nodes: http://jenkins-ip:8080/computer/
- Plugins: http://jenkins-ip:8080/pluginManager/

---

## 🎉 Final Note

You now have a complete, organized structure for all 5 Jenkins tasks. Each task builds on the previous one, creating a comprehensive CI/CD platform.

**Start with Task 1, complete it fully, then move to Task 2.**

Good luck! 🚀

---

**Created**: April 25, 2026
**Version**: 1.0
**Status**: Ready for Execution
