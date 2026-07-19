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
    if (project.name == "file_picker" || project.name == "package_info_plus" || project.name == "wakelock_plus" || project.name == "android_alarm_manager_plus" || project.name == "sensors_plus") {
        if (!project.plugins.hasPlugin("org.jetbrains.kotlin.android") && !project.plugins.hasPlugin("kotlin-android")) {
            try {
                project.plugins.apply("org.jetbrains.kotlin.android")
            } catch (ignored: Exception) {}
        }
    }
    afterEvaluate {
        if (project.name == "file_picker" || project.name == "package_info_plus" || project.name == "wakelock_plus" || project.name == "android_alarm_manager_plus" || project.name == "sensors_plus") {
            if (!project.plugins.hasPlugin("org.jetbrains.kotlin.android") && !project.plugins.hasPlugin("kotlin-android")) {
                try {
                    project.plugins.apply("org.jetbrains.kotlin.android")
                } catch (ignored: Exception) {}
            }
        }
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
            try {
                val getCompileOptions = android.javaClass.getMethod("getCompileOptions")
                val compileOptions = getCompileOptions.invoke(android)
                if (compileOptions != null) {
                    val setSource = compileOptions.javaClass.getMethod("setSourceCompatibility", org.gradle.api.JavaVersion::class.java)
                    val setTarget = compileOptions.javaClass.getMethod("setTargetCompatibility", org.gradle.api.JavaVersion::class.java)
                    setSource.invoke(compileOptions, org.gradle.api.JavaVersion.VERSION_17)
                    setTarget.invoke(compileOptions, org.gradle.api.JavaVersion.VERSION_17)
                }
            } catch (ignored: Exception) {}
        }
        try {
            project.tasks.configureEach {
                if (this.name.contains("Kotlin")) {
                    try {
                        val getCompilerOptions = this.javaClass.getMethod("getCompilerOptions")
                        val compilerOpts = getCompilerOptions.invoke(this)
                        val getJvmTarget = compilerOpts.javaClass.getMethod("getJvmTarget")
                        val jvmTargetProp = getJvmTarget.invoke(compilerOpts)
                        val setMethod = jvmTargetProp.javaClass.getMethod("set", Any::class.java)
                        setMethod.invoke(jvmTargetProp, org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                    } catch (ignored: Exception) {
                        try {
                            val getKotlinOptions = this.javaClass.getMethod("getKotlinOptions")
                            val kotlinOpts = getKotlinOptions.invoke(this)
                            val setJvmTarget = kotlinOpts.javaClass.getMethod("setJvmTarget", String::class.java)
                            setJvmTarget.invoke(kotlinOpts, "17")
                        } catch (ignored2: Exception) {}
                    }
                }
            }
        } catch (ignored: Exception) {}
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
