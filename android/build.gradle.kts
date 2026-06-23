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

// Normalize the Kotlin JVM target to 17 for every module. Wrapped in
// projectsEvaluated so our configureEach is registered AFTER each plugin sets its
// own target (e.g. workmanager pins 1.8). For configureEach, registration order
// decides the winner — registering last makes ours win, matching the Java 17
// target pinned in the afterEvaluate block below.
gradle.projectsEvaluated {
    subprojects {
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }
}

// Some older Flutter plugins (e.g. on_audio_query) predate AGP's mandatory
// `namespace` rule and only declare a `package` in their AndroidManifest. AGP 9
// rejects that ("Namespace not specified"). Inject the namespace from the
// manifest package for any subproject that's missing one. Reflection keeps this
// decoupled from a specific AGP version's DSL types.
subprojects {
    // :app is force-evaluated early by the evaluationDependsOn block above, so
    // only register afterEvaluate on projects that aren't evaluated yet
    // (:app already declares a namespace, so skipping it is harmless).
    if (!project.state.executed) {
        afterEvaluate {
            val android = project.extensions.findByName("android") ?: return@afterEvaluate
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                if (getNamespace.invoke(android) == null) {
                    val manifest = project.file("src/main/AndroidManifest.xml")
                    if (manifest.exists()) {
                        val pkg = Regex("package=\"([^\"]+)\"")
                            .find(manifest.readText())
                            ?.groupValues?.get(1)
                        if (pkg != null) {
                            android.javaClass
                                .getMethod("setNamespace", String::class.java)
                                .invoke(android, pkg)
                            logger.lifecycle("Injected namespace '$pkg' into :${project.name}")
                        }
                    }
                }
            } catch (e: Exception) {
                // Extension shape differs from what we expect; leave it untouched.
            }

            // Pin Java source/target compatibility to 17 so it matches the
            // Kotlin target. AGP derives the Java task target from the android
            // extension's compileOptions, not from the JavaCompile task props.
            try {
                val compileOptions =
                    android.javaClass.getMethod("getCompileOptions").invoke(android)
                compileOptions.javaClass
                    .getMethod("setSourceCompatibility", Any::class.java)
                    .invoke(compileOptions, JavaVersion.VERSION_17)
                compileOptions.javaClass
                    .getMethod("setTargetCompatibility", Any::class.java)
                    .invoke(compileOptions, JavaVersion.VERSION_17)
            } catch (e: Exception) {
                // Couldn't set compileOptions; rely on the plugin's own config.
            }

            // Some legacy plugins pin an old compileSdk (e.g. on_audio_query uses
            // 33) whose AndroidX dependencies now require 34+. Bump plugin modules
            // to 36 (matches the app's flutter.compileSdkVersion + installed SDK).
            try {
                android.javaClass
                    .getMethod("setCompileSdk", Integer::class.java)
                    .invoke(android, 36)
            } catch (e: Exception) {
                try {
                    android.javaClass
                        .getMethod("setCompileSdkVersion", Integer.TYPE)
                        .invoke(android, 36)
                } catch (e2: Exception) {
                    // Leave the plugin's own compileSdk in place.
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
