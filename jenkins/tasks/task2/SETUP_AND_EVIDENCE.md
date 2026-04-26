# Task 2 Setup and Evidence Guide

## 1. Create Multibranch Pipeline Job

1. Jenkins Dashboard -> New Item -> Multibranch Pipeline.
2. Name it: `task2-node-express`.
3. Branch Sources -> GitHub.
4. Add repository URL: `https://github.com/nasif1731/bankManagementSystem`.
5. Credentials: select your GitHub PAT credential.
6. Build Configuration -> Script Path:
   - `jenkins/tasks/task2/Jenkinsfile`
7. Save.

## 2. Configure GitHub Webhook

1. In GitHub repo: Settings -> Webhooks -> Add webhook.
2. Payload URL:
   - `http://<jenkins-public-ip>:8080/github-webhook/`
3. Content type: `application/json`.
4. Events: `Just the push event` and `Pull requests`.
5. Save webhook.
6. In Jenkins, click Scan Repository Now once.

## 3. Jenkins Credentials for Slack

Create credential:

- Kind: Secret text
- ID: `slack-webhook`
- Secret: your Slack incoming webhook URL

## 4. Successful Build Evidence

1. Push latest code to a branch (for example `main`).
2. Wait for Jenkins to discover and run build.
3. Capture screenshots:
   - Blue Ocean full pipeline showing Checkout, Build, Test, Package, Deploy.
   - Inside `Test` stage, parallel view with `Unit Tests` and `Integration Tests`.
   - JUnit test report page showing both published reports.
   - Slack success notification with build URL.

## 5. Intentional Failure Build Evidence

1. Create branch `task2-fail-demo`.
2. Intentionally break one test, for example in `app/tests/unit/banking.test.js`:
   - Change one expected value to wrong value.
3. Commit and push branch.
4. Open a PR to `main`.
5. Capture screenshots:
   - Failed pipeline run in Jenkins.
   - Slack failure message that includes failing stage name.
   - PR page with Jenkins status check (failed).

## 6. Restore and Show Passing PR

1. Fix the broken test in same branch.
2. Push again.
3. Capture screenshot of PR status check turning green.

## 7. Quick Commands for Local Validation

Run from repository root:

```powershell
cd app
npm ci
npm run build
npm run test:unit
npm run test:integration
npm run package
npm run deploy
```

You should see JUnit files at:

- `app/reports/junit/unit/junit.xml`
- `app/reports/junit/integration/junit.xml`
