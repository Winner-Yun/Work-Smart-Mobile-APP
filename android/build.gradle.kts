allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val applyNamespaceFallback: () -> Unit = fallback@{
        val androidExt = extensions.findByName("android") ?: return@fallback

        try {
            val currentNamespace = androidExt.javaClass
                .getMethod("getNamespace")
                .invoke(androidExt) as? String

            if (currentNamespace.isNullOrBlank()) {
                val fallbackNamespace = if (group.toString().isNotBlank() && group.toString() != "unspecified") {
                    group.toString()
                } else {
                    "com.worksmart.${name.replace('-', '_')}"
                }

                androidExt.javaClass
                    .getMethod("setNamespace", String::class.java)
                    .invoke(androidExt, fallbackNamespace)
            }
        } catch (_: Exception) {
            // Ignore modules/extensions that do not expose namespace APIs.
        }
    }

    if (state.executed) {
        applyNamespaceFallback()
    } else {
        afterEvaluate {
            applyNamespaceFallback()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
