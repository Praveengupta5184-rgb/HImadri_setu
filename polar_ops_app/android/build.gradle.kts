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
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
        
        project.afterEvaluate {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val setCompileSdk = android.javaClass.getMethod("setCompileSdk", java.lang.Integer::class.java)
                    setCompileSdk.invoke(android, 36)
                } catch (e: Exception) {
                    try {
                        val compileSdkVersion = android.javaClass.getMethod("compileSdkVersion", java.lang.Integer::class.java)
                        compileSdkVersion.invoke(android, 36)
                    } catch (e2: Exception) {}
                }

                try {
                    val defaultConfig = android.javaClass.getMethod("getDefaultConfig").invoke(android)
                    try {
                        val setTargetSdk = defaultConfig.javaClass.getMethod("setTargetSdk", java.lang.Integer::class.java)
                        setTargetSdk.invoke(defaultConfig, 36)
                    } catch (e: Exception) {
                        try {
                            val targetSdkVersion = defaultConfig.javaClass.getMethod("targetSdkVersion", java.lang.Integer::class.java)
                            targetSdkVersion.invoke(defaultConfig, 36)
                        } catch (e2: Exception) {}
                    }
                } catch (e: Exception) {}
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
