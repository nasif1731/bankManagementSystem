# Jenkins Shared Library Reference

This directory contains references and examples for implementing Jenkins Groovy Shared Libraries (Task 2 and beyond).

## What is a Groovy Shared Library?

A Jenkins Shared Library is a collection of reusable Groovy code that can be used across multiple Jenkinsfiles. It helps:
- **Reduce code duplication** - Common functionality in one place
- **Standardize pipelines** - Consistent patterns across jobs
- **Centralized maintenance** - Update once, applies everywhere
- **Team collaboration** - Share proven patterns

## Structure

```
shared-library/
├── vars/                           # Global variables/functions
│   ├── checkoutCode.groovy
│   ├── buildArtifact.groovy
│   ├── runTests.groovy
│   ├── deployToAWS.groovy
│   └── notifySlack.groovy
│
├── src/                            # Library code (classes/utilities)
│   └── com/
│       └── jenkins/
│           ├── DockerUtils.groovy
│           ├── AWSUtils.groovy
│           ├── GitUtils.groovy
│           └── Constants.groovy
│
└── README.md                       # This file
```

## Example: Global Variable (vars/)

File: `vars/checkoutCode.groovy`

```groovy
def call(String repo, String branch = 'main') {
    stage('Checkout Code') {
        checkout([
            $class: 'GitSCM',
            branches: [[name: "${branch}"]],
            userRemoteConfigs: [[url: repo]]
        ])
    }
}
```

Usage in Jenkinsfile:
```groovy
@Library('shared-library') _
pipeline {
    stages {
        stage('SCM') {
            steps {
                checkoutCode('https://github.com/example/repo.git', 'main')
            }
        }
    }
}
```

## Example: Utility Class (src/)

File: `src/com/jenkins/DockerUtils.groovy`

```groovy
package com.jenkins

class DockerUtils {
    static void buildImage(String dockerfile, String imageName, String imageTag) {
        sh "docker build -f ${dockerfile} -t ${imageName}:${imageTag} ."
    }
    
    static void pushImage(String imageName, String imageTag, String registry) {
        sh "docker push ${registry}/${imageName}:${imageTag}"
    }
}
```

Usage in Jenkinsfile:
```groovy
@Library('shared-library') _
import com.jenkins.DockerUtils

pipeline {
    stages {
        stage('Build Docker') {
            steps {
                script {
                    DockerUtils.buildImage('Dockerfile', 'my-app', '1.0.0')
                    DockerUtils.pushImage('my-app', '1.0.0', 'my-registry')
                }
            }
        }
    }
}
```

## Registering the Shared Library

1. **GitHub Repository**:
   - Create a repository: `jenkins-shared-library`
   - Push the library code

2. **Configure in Jenkins**:
   - Go to **Manage Jenkins** → **Configure System**
   - Scroll to **Global Pipeline Libraries**
   - Click **Add**:
     - **Name**: `shared-library`
     - **Default version**: `main`
     - **Modern SCM**: Select GitHub
     - **Repository**: `github-owner/jenkins-shared-library`

3. **Use in Jenkinsfile**:
   ```groovy
   @Library('shared-library') _
   
   pipeline {
       // Your pipeline code
   }
   ```

## Best Practices

1. **Version Control**: Keep library in separate Git repo
2. **Documentation**: Comment all functions with purpose
3. **Testing**: Write unit tests for library code
4. **Naming**: Use clear, descriptive names for variables/functions
5. **Avoid Secrets**: Never hardcode credentials
6. **Modular**: Create small, focused functions
7. **Error Handling**: Include try-catch blocks where needed

## Task 2 Requirements

For the full assignment, you need to:
1. Create a reusable Groovy shared library
2. Implement at least 3-5 shared functions/classes
3. Document each function
4. Use in your declarative pipeline
5. Demonstrate during viva that you understand the code

## Common Shared Library Functions

1. **checkoutCode()** - Clone repository
2. **buildArtifact()** - Compile/build application
3. **runTests()** - Execute unit tests
4. **runSonarScan()** - Code quality analysis
5. **deployToAWS()** - Deploy using Terraform/CloudFormation
6. **deployToECR()** - Push Docker image to ECR
7. **notifySlack()** - Send Slack notifications
8. **deployBlueGreen()** - Blue-Green deployment
9. **validateTerraform()** - Validate Terraform files
10. **scaleInfrastructure()** - Auto-scale based on metrics

## Resources

- [Jenkins Shared Library Documentation](https://www.jenkins.io/doc/book/pipeline/shared-libraries/)
- [Groovy Documentation](https://groovy-lang.org/documentation.html)
- [Pipeline Steps Reference](https://www.jenkins.io/doc/pipeline/steps/)

## Important Notes for Viva

You will be asked to:
1. Explain what each shared library function does
2. Modify a stage/function live
3. Trace a failed build through logs
4. Justify design decisions

Therefore:
- **Write your own code** - Don't copy from online
- **Understand every line** - Be able to explain it
- **Test thoroughly** - Ensure functions work
- **Document well** - Comments and README

---

**Next Steps**: Implement your shared library in Task 2 with original code.
