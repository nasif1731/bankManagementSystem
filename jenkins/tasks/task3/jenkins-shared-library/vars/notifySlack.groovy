import org.yourteam.NotificationService

def call(Map config = [:]) {
    List<String> required = ["message", "credentialId"]
    List<String> missing = required.findAll { !config.containsKey(it) || !config[it]?.toString()?.trim() }

    if (!missing.isEmpty()) {
        error("notifySlack missing required keys: ${missing.join(', ')}")
    }

    withCredentials([string(credentialsId: config.credentialId, variable: 'SLACK_WEBHOOK')]) {
        NotificationService service = new NotificationService(this)
        service.sendSlack(config.message.toString())
    }
}
