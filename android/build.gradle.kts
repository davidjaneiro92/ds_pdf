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

// Alguns plugins mais antigos (ex.: uri_to_file) ainda não declaram
// "namespace" no próprio build.gradle, exigido pelo Android Gradle Plugin
// usado por este projeto — sem isso, o build falha com "Namespace not
// specified". Usamos o "group" do próprio módulo (que esses plugins antigos
// sempre declaram) como namespace de fallback, só para quem realmente não
// declarou um.
subprojects {
    afterEvaluate {
        val androidExtension = extensions.findByName("android")
        if (androidExtension is com.android.build.gradle.BaseExtension) {
            if (androidExtension.namespace == null) {
                androidExtension.namespace = project.group.toString()
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
