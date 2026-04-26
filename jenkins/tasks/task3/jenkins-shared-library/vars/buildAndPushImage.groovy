import org.yourteam.DockerHelper

def call(Map config = [:]) {
    List<String> required = ["name", "tag"]
    List<String> missing = required.findAll { !config.containsKey(it) || !config[it]?.toString()?.trim() }

    if (!missing.isEmpty()) {
        error("buildAndPushImage missing required keys: ${missing.join(', ')}")
    }

    DockerHelper helper = new DockerHelper(this)
    helper.buildImage(config.name.toString(), config.tag.toString())
    helper.pushImage(config.name.toString(), config.tag.toString())
}
