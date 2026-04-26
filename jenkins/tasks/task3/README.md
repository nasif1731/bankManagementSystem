# Task 3: Code Quality with SonarQube and Docker ECR

## Overview

Task 3 integrates code quality scanning with SonarQube and builds/pushes Docker images to AWS ECR.

## What You'll Do

1. **Integrate SonarQube scanner** into pipeline
2. **Build Docker image** from Dockerfile
3. **Push image to AWS ECR** (Elastic Container Registry)
4. **Implement quality gates** (fail if code quality issues)
5. **Scan Docker image** for vulnerabilities
6. **Archive artifacts** for deployment

## Pipeline Stages

```
1. Checkout Code (from Task 2 library)
   ↓
2. Build Artifact (from Task 2 library)
   ↓
3. SonarQube Scan (CODE QUALITY)
   ↓
4. Build Docker Image
   ↓
5. Push to ECR
   ↓
6. Cleanup & Archive
```

## Deliverables

- [ ] Jenkinsfile with SonarQube integration
- [ ] Dockerfile for application
- [ ] ECR repository created in AWS
- [ ] Pipeline successfully scans code quality
- [ ] Docker image pushed to ECR
- [ ] Screenshots showing:
  - SonarQube dashboard with results
  - ECR repository with pushed image
  - Pipeline success
  - Code metrics

## Key Configuration

### SonarQube Setup
```groovy
withSonarQubeEnv('SonarQube') {
    sh '''
        mvn clean verify \
            -Dsonar.login=${SONARQUBE_TOKEN}
    '''
}
```

### Docker Build & Push
```groovy
sh '''
    # Login to ECR
    aws ecr get-login-password --region us-east-1 | \
        docker login --username AWS --password-stdin <ECR_URI>
    
    # Build image
    docker build -t my-app:${BUILD_NUMBER} .
    
    # Tag for ECR
    docker tag my-app:${BUILD_NUMBER} <ECR_URI>/my-app:${BUILD_NUMBER}
    
    # Push to ECR
    docker push <ECR_URI>/my-app:${BUILD_NUMBER}
'''
```

## Files to Create

```
jenkins/tasks/task3/
├── Jenkinsfile              # Pipeline with SonarQube + Docker
├── README.md               # This file
├── Dockerfile              # Docker image definition
└── sonar-project.properties # SonarQube configuration
```

## Status

- [ ] SonarQube instance running (could be local/cloud)
- [ ] SonarQube token created and stored in Jenkins
- [ ] ECR repository created in AWS
- [ ] Dockerfile created for application
- [ ] Jenkinsfile implements all stages
- [ ] Pipeline successfully executes
- [ ] Images pushed to ECR
- [ ] Code quality gates working

---

**Next Task**: Task 4 - Blue-Green Deployment
