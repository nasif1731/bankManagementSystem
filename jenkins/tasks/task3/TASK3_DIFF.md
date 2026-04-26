# Task 3 Jenkinsfile Refactor Diff (Task 2 -> Shared Library)

## Before (direct Slack curl in post)

```groovy
post {
  success {
    script {
      // curl call to Slack webhook
    }
  }
  failure {
    script {
      // curl call to Slack webhook
    }
  }
}
```

## After (shared library step)

```groovy
@Library('your-lib') _

post {
  success {
    script {
      notifySlack(
        message: "SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER} - ${env.BUILD_URL}",
        credentialId: 'slack-webhook'
      )
    }
  }
  failure {
    script {
      notifySlack(
        message: "FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER} failed at stage ${env.FAILED_STAGE}. Build: ${env.BUILD_URL}",
        credentialId: 'slack-webhook'
      )
    }
  }
}
```

## File changed for Task 3

- `jenkins/tasks/task3/Jenkinsfile`
