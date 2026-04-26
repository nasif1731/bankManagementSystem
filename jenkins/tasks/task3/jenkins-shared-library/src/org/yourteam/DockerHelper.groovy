package org.yourteam

class DockerHelper {
    private final def script

    DockerHelper(script) {
        this.script = script
    }

    void buildImage(String name, String tag) {
        if (!name?.trim() || !tag?.trim()) {
            throw new IllegalArgumentException("name and tag are required")
        }

        script.sh "docker build -t ${name}:${tag} ."
    }

    void pushImage(String name, String tag) {
        if (!name?.trim() || !tag?.trim()) {
            throw new IllegalArgumentException("name and tag are required")
        }

        script.sh "docker push ${name}:${tag}"
    }
}
