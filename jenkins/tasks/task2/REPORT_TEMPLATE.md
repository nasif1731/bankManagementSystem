# Task 2 Report: Declarative Pipeline with Parallel Stages and Notifications

## Student Information

- Name:
- Roll Number:
- Date:
- Repository: https://github.com/nasif1731/bankManagementSystem

## 1. Application Summary

- Technology: Node.js + Express
- Location: `app/`
- REST endpoint implemented: `GET /health`
- Unit tests: 6
- Integration tests: 3

Evidence:

- Screenshot: app endpoint test or app run output
- Screenshot: unit test summary
- Screenshot: integration test summary

## 2. Jenkins Declarative Pipeline

Pipeline files:

- Root Jenkinsfile: `Jenkinsfile`
- Task 2 Jenkinsfile: `jenkins/tasks/task2/Jenkinsfile`

Required stage order implemented:

1. Checkout
2. Build
3. Test
4. Package
5. Deploy

Evidence:

- Screenshot: Jenkins pipeline stage list (classic view)
- Screenshot: Blue Ocean full successful run

## 3. Parallel Test Stage

Test stage configuration:

- `Unit Tests` and `Integration Tests` run in `parallel {}`
- `failFast true` enabled
- Each branch publishes JUnit report

JUnit paths:

- `app/reports/junit/unit/junit.xml`
- `app/reports/junit/integration/junit.xml`

Evidence:

- Screenshot: Blue Ocean parallel view inside Test stage
- Screenshot: JUnit test report page with both suites

## 4. Agent and Credentials

- Pipeline-level agent: `linux-agent`
- Pipeline-level secret injection via `credentials()`:
  - `SLACK_WEBHOOK = credentials('slack-webhook')`

Evidence:

- Screenshot: Jenkinsfile snippet in UI or repo
- Screenshot: Jenkins Credentials page showing credential ID (secret masked)

## 5. Post Actions and Notifications

Pipeline-level `post` handlers implemented:

- `always`: archive artifacts and JUnit xml files
- `success`: send Slack message with build URL
- `failure`: send Slack message including failing stage name

Evidence:

- Screenshot: archived artifacts after run
- Screenshot: Slack success message
- Screenshot: Slack failure message

## 6. Multibranch Pipeline + GitHub Webhook

Configuration summary:

- Jenkins job type: Multibranch Pipeline
- Script path: `jenkins/tasks/task2/Jenkinsfile`
- GitHub webhook URL: `http://<jenkins-host>:8080/github-webhook/`
- Events enabled: Push + Pull Requests

Evidence:

- Screenshot: Multibranch job config
- Screenshot: GitHub webhook configuration and recent deliveries
- Screenshot: PR page showing Jenkins status check

## 7. Successful Build Demonstration

- Branch used:
- Build number:
- Build URL:

Evidence:

- Screenshot: successful build in Blue Ocean
- Screenshot: stage logs confirming Unit + Integration pass

## 8. Intentionally Failing Build Demonstration

Failure method:

- Branch created (example): `task2-fail-demo`
- One test assertion intentionally changed to fail

Details:

- File modified:
- Test name modified:

Evidence:

- Screenshot: failed build showing failing test branch
- Screenshot: Slack failure notification
- Screenshot: PR status check failed

## 9. Recovery Demonstration

- Broken test reverted/fixed
- New build triggered automatically

Evidence:

- Screenshot: fixed build success
- Screenshot: PR status check turned green

## 10. Conclusion

- All Task 2 requirements completed: Yes / No
- Notes:

## Appendix: Local Validation Commands

```powershell
cd app
npm ci
npm run build
npm run test:unit
npm run test:integration
npm run package
npm run deploy
```
