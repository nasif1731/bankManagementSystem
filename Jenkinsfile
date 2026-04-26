pipeline {
  agent { label 'linux-agent' }

  options {
    timestamps()
    skipDefaultCheckout(true)
  }

  environment {
    SLACK_WEBHOOK = credentials('slack-webhook')
    FAILED_STAGE = 'Unknown'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
      post {
        failure {
          script {
            env.FAILED_STAGE = env.STAGE_NAME
          }
        }
      }
    }

    stage('Setup Node') {
      steps {
        sh '''
          set -e
          if ! command -v npm >/dev/null 2>&1; then
            echo "npm not found, installing Node.js 20..."
            curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
            sudo yum install -y nodejs
          fi
          node -v
          npm -v
        '''
      }
      post {
        failure {
          script {
            env.FAILED_STAGE = env.STAGE_NAME
          }
        }
      }
    }

    stage('Build') {
      steps {
        dir('app') {
          sh 'npm ci'
          sh 'npm run build'
        }
      }
      post {
        failure {
          script {
            env.FAILED_STAGE = env.STAGE_NAME
          }
        }
      }
    }

    stage('Test') {
      failFast true
      parallel {
        stage('Unit Tests') {
          steps {
            dir('app') {
              sh 'npm install'
              sh 'npm run test:unit'
            }
          }
          post {
            always {
              junit allowEmptyResults: false, testResults: 'app/reports/junit/unit/junit.xml'
            }
            failure {
              script {
                env.FAILED_STAGE = env.STAGE_NAME
              }
            }
          }
        }

        stage('Integration Tests') {
          steps {
            dir('app') {
              sh 'npm install'
              sh 'npm run test:integration'
            }
          }
          post {
            always {
              junit allowEmptyResults: false, testResults: 'app/reports/junit/integration/junit.xml'
            }
            failure {
              script {
                env.FAILED_STAGE = env.STAGE_NAME
              }
            }
          }
        }
      }
      post {
        failure {
          script {
            if (!env.FAILED_STAGE || env.FAILED_STAGE == 'Unknown') {
              env.FAILED_STAGE = env.STAGE_NAME
            }
          }
        }
      }
    }

    stage('Package') {
      steps {
        dir('app') {
          sh 'npm run package'
        }
      }
      post {
        failure {
          script {
            env.FAILED_STAGE = env.STAGE_NAME
          }
        }
      }
    }

    stage('Deploy') {
      steps {
        dir('app') {
          sh 'npm run deploy'
        }
      }
      post {
        failure {
          script {
            env.FAILED_STAGE = env.STAGE_NAME
          }
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'app/dist/*.tgz, app/reports/junit/**/*.xml', allowEmptyArchive: true
    }

    success {
      script {
        sh """
          curl -s -X POST -H 'Content-type: application/json' \\
          --data '{"text":"SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER} - ${env.BUILD_URL}"}' \\
          "$SLACK_WEBHOOK" || true
        """
      }
    }

    failure {
      script {
        sh """
          curl -s -X POST -H 'Content-type: application/json' \\
          --data '{"text":"FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER} failed at stage ${env.FAILED_STAGE}. Build: ${env.BUILD_URL}"}' \\
          "$SLACK_WEBHOOK" || true
        """
      }
    }
  }
}
