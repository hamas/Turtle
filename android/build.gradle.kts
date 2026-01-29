allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = layout.projectDirectory.dir("../build")
layout.buildDirectory.value(newBuildDir)

subprojects {
    val subprojectBuildDir = newBuildDir.dir(project.name)
    layout.buildDirectory.value(subprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
