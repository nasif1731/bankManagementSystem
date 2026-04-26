# Task 1: Sanity-Check Pipeline

## Overview

This is the first pipeline job that verifies your Jenkins setup is working correctly.

## What It Does

The pipeline runs 8 stages on the `linux-agent`:
1. **Verify Agent Connection** - Confirm agent is responding
2. **Verify Java** - Check Java 17 is installed
3. **Verify Git** - Check Git is available
4. **Verify Docker** - Check Docker is installed
5. **Verify AWS CLI** - Check AWS CLI is available
6. **Verify Terraform** - Check Terraform is installed
7. **System Information** - Display system specs
8. **Final Verification** - Success summary

## How to Run

### Method 1: Jenkins UI
1. Go to Jenkins Dashboard
2. Click **New Item**
3. Name: `sanity-check-pipeline`
4. Type: **Pipeline**
5. Copy content from `Jenkinsfile` into Pipeline Script box
6. Click **Save**
7. Click **Build Now**

### Method 2: From Git Repository
If you have this repo in Git:
1. Create new **Multibranch Pipeline** job
2. **Script Path**: `jenkins/tasks/task1/Jenkinsfile`
3. Jenkins auto-triggers on code changes

## Expected Output

Successful run should show:
```
✓ Agent Hostname: ip-10-0-3-42.ec2.internal
✓ Current User: jenkins
✓ java -version (Java 17)
✓ git --version
✓ docker --version
✓ aws --version
✓ terraform version
✓ SUCCESS - Sanity Check Passed!
```

## Troubleshooting

### Pipeline runs on master instead of agent
- Verify agent is **online** in Manage Nodes
- Check agent label is exactly `linux-agent` (case-sensitive)
- Pipeline must have `agent { label 'linux-agent' }`

### Tools show as "not found"
- SSH to agent and verify tools are installed
- Check if tools are in PATH: `which java`, `which git`, etc.
- May need to re-run init script

### Pipeline times out
- Increase timeout in `options` section (default: 10 minutes)
- Check if agent is responding: try SSH connection
- May be network issue with AWS API calls

## Next Steps

After this succeeds:
1. All infrastructure is working ✅
2. Ready to create Groovy shared libraries (Task 2)
3. Ready for SonarQube integration (Task 3)
4. Ready for Docker/ECR pipeline (Task 3)

## Key Concepts

### `agent { label 'linux-agent' }`
- Specifies this job runs on agent with label "linux-agent"
- MUST match the label configured in Manage Nodes
- Jobs without explicit agent run on controller (not recommended)

### Stages
- Sequential steps that run one after another
- Failure in one stage stops the pipeline
- Each stage is visible in Jenkins UI and Blue Ocean

### Post Actions
- Run after all stages complete (success or failure)
- `always` - runs regardless of result
- `success` - only if all stages passed
- `failure` - only if any stage failed

## Pipeline Execution Flow

```
Start
  ↓
[Verify Agent Connection] ✓
  ↓
[Verify Java] ✓
  ↓
[Verify Git] ✓
  ↓
[Verify Docker] ✓
  ↓
[Verify AWS CLI] ✓
  ↓
[Verify Terraform] ✓
  ↓
[System Information] ✓
  ↓
[Final Verification] ✓
  ↓
[Post: Success Actions]
  ↓
SUCCESS ✅
```

## Modifying the Pipeline

To add your own verifications:

```groovy
stage('My Custom Check') {
    steps {
        sh '''
            # Your custom commands here
            echo "Running my check..."
        '''
    }
}
```

Add this as a new stage between existing stages.

---

**Status**: ✅ Task 1 Complete (when pipeline succeeds)
