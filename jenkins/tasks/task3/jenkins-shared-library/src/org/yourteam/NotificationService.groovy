package org.yourteam

class NotificationService {
    private final def script

    NotificationService(script) {
        this.script = script
    }

    void sendSlack(String message) {
        if (!message?.trim()) {
            throw new IllegalArgumentException("message is required")
        }

        script.sh(
            script: """
                set +e
                payload='{"text":"${message.replace("\"", "\\\"")}"}'
                curl -sS -X POST -H 'Content-type: application/json' --data "$payload" "$SLACK_WEBHOOK"
            """,
            label: "Send Slack notification"
        )
    }

    void sendEmail(String to, String subject, String body) {
        if (!to?.trim() || !subject?.trim() || !body?.trim()) {
            throw new IllegalArgumentException("to, subject, and body are required")
        }

        script.emailext(
            to: to,
            subject: subject,
            body: body,
            mimeType: "text/plain"
        )
    }
}
