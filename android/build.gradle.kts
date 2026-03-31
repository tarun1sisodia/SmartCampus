allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fixed: Base the build directory on projectDirectory to avoid circular references
rootProject.layout.buildDirectory.value(rootProject.layout.projectDirectory.dir("../build"))

subprojects {
    // Each subproject (like :app) gets its own folder inside the shared build directory
    project.layout.buildDirectory.value(rootProject.layout.buildDirectory.dir(project.name))
    
    // Ensure all subprojects wait for :app evaluation
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
