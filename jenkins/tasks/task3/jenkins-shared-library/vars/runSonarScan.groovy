def call(Map config = [:]) {
    List<String> required = ["projectKey", "hostUrl", "tokenCredentialId"]
    List<String> missing = required.findAll { !config.containsKey(it) || !config[it]?.toString()?.trim() }

    if (!missing.isEmpty()) {
        error("runSonarScan missing required keys: ${missing.join(', ')}")
    }

    withCredentials([string(credentialsId: config.tokenCredentialId, variable: 'SONAR_TOKEN')]) {
        sh """
            sonar-scanner \\
              -Dsonar.projectKey=${config.projectKey} \\
              -Dsonar.host.url=${config.hostUrl} \\
              -Dsonar.login=$SONAR_TOKEN
        """
    }
}
