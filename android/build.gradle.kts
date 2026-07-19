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
    afterEvaluate {
        val android = project.extensions.findByName("android")
        if (android != null) {
            try {
                val setCompileSdk = android.javaClass.getMethod("setCompileSdkVersion", Int::class.java)
                setCompileSdk.invoke(android, 36)
            } catch (e: Exception) {
                try {
                    val setCompileSdk = android.javaClass.getMethod("setCompileSdk", Int::class.java)
                    setCompileSdk.invoke(android, 36)
                } catch (ignored: Exception) {}
            }
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val ns = getNamespace.invoke(android)
                if (ns == null || ns.toString().isEmpty()) {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    val groupStr = project.group.toString()
                    val newNs = if (groupStr.contains(".") && groupStr != "unspecified") {
                        groupStr
                    } else {
                        "com.focusalarm.plugins." + project.name.replace("-", "_")
                    }
                    setNamespace.invoke(android, newNs)
                }
            } catch (ignored: Exception) {}
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
