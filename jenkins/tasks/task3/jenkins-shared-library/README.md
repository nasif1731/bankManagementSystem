# jenkins-shared-library

This folder is ready to be pushed as a separate GitHub repository named `jenkins-shared-library`.

## Standard Layout

- `vars/` global steps callable from Jenkinsfiles
- `src/org/yourteam/` Groovy classes

## Classes

### `org.yourteam.NotificationService`

- Constructor: `NotificationService(script)`
- Methods:
  - `sendSlack(message)`
  - `sendEmail(to, subject, body)`

Purpose:

- Encapsulates notification logic while using the Jenkins script context.

### `org.yourteam.DockerHelper`

- Constructor: `DockerHelper(script)`
- Methods:
  - `buildImage(name, tag)`
  - `pushImage(name, tag)`

Purpose:

- Encapsulates Docker build/push operations in reusable OOP form.

## Global vars (steps)

### `notifySlack.groovy`

Usage:

```groovy
notifySlack(
  message: "Pipeline succeeded",
  credentialId: "slack-webhook"
)
```

Required keys:

- `message`
- `credentialId`

### `buildAndPushImage.groovy`

Usage:

```groovy
buildAndPushImage(
  name: "my-app",
  tag: "1.0.0"
)
```

Required keys:

- `name`
- `tag`

### `runSonarScan.groovy`

Usage:

```groovy
runSonarScan(
  projectKey: "bank-app",
  hostUrl: "http://sonarqube.local:9000",
  tokenCredentialId: "sonarqube-token"
)
```

Required keys:

- `projectKey`
- `hostUrl`
- `tokenCredentialId`

## Jenkins Registration

In Jenkins:

1. Manage Jenkins -> System
2. Global Pipeline Libraries -> Add
3. Name: `your-lib`
4. Default version: `main`
5. Load implicitly: disabled
6. Retrieval method: Modern SCM (Git)
7. Repository URL: your separate `jenkins-shared-library` repo URL

## Minimal Jenkinsfile Example

```groovy
@Library('your-lib') _

pipeline {
  agent any
  stages {
    stage('Notify') {
      steps {
        notifySlack(message: "Hello from shared library", credentialId: "slack-webhook")
      }
    }
  }
}
```
