# Task 3: Reusable Jenkins Shared Library in Groovy

## Overview

This folder contains everything required for Task 3 in its own location:

- Shared library scaffold ready to publish as a separate repo `jenkins-shared-library`
- Refactored Jenkinsfile that explicitly loads `@Library('your-lib') _`
- Before/after diff reference for the Slack refactor

## Folder Structure

```
jenkins/tasks/task3/
├── Jenkinsfile
├── README.md
├── TASK3_DIFF.md
└── jenkins-shared-library/
    ├── README.md
    ├── vars/
    │   ├── notifySlack.groovy
    │   ├── buildAndPushImage.groovy
    │   └── runSonarScan.groovy
    └── src/org/yourteam/
        ├── NotificationService.groovy
        └── DockerHelper.groovy
```

## Requirement Mapping

1. Separate repository `jenkins-shared-library`:
   - Scaffold is available in `jenkins/tasks/task3/jenkins-shared-library/`
   - Push this folder as a standalone GitHub repository.

2. Global library registration in Jenkins:
   - Name: `your-lib`
   - Default version: `main`
   - Load implicitly: disabled
   - Pipelines load explicitly with `@Library('your-lib') _`

3. Groovy classes in `src/org/yourteam/`:
   - `NotificationService`:
     - `sendSlack(message)`
     - `sendEmail(to, subject, body)`
   - `DockerHelper`:
     - `buildImage(name, tag)`
     - `pushImage(name, tag)`

4. Global vars with Map validation:
   - `notifySlack.groovy`
   - `buildAndPushImage.groovy`
   - `runSonarScan.groovy`

5. Task 2 Jenkinsfile refactor:
   - Refactored version is in `jenkins/tasks/task3/Jenkinsfile`
   - Slack post calls replaced by `notifySlack(...)`

6. Shared library README:
   - Included at `jenkins/tasks/task3/jenkins-shared-library/README.md`
   - Contains class/var explanations and minimal usage example

## Jenkins Setup Steps

1. Create a new GitHub repository named `jenkins-shared-library`.
2. Copy contents of `jenkins/tasks/task3/jenkins-shared-library/` into that repo.
3. Push to `main` branch.
4. In Jenkins:
   - Manage Jenkins -> System -> Global Pipeline Libraries -> Add
   - Name: `your-lib`
   - Default version: `main`
   - Disable `Load implicitly`
   - Add Git repository URL of `jenkins-shared-library`
5. Update pipeline script path for Task 3 job to:
   - `jenkins/tasks/task3/Jenkinsfile`

## Deliverables Checklist

- Link to `jenkins-shared-library` GitHub repository
- Screenshot: Jenkins Global Pipeline Libraries registration
- Build log excerpt showing:
  - `Loading library your-lib@main`
- Before/after diff showing Slack post refactor:
  - `jenkins/tasks/task3/TASK3_DIFF.md`
