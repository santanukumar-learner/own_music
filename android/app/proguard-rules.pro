# Keep rules for reflection-heavy native bindings, used only if you enable R8
# (minifyEnabled = true) in app/build.gradle.

# ONNX Runtime
-keep class ai.onnxruntime.** { *; }
-dontwarn ai.onnxruntime.**

# Isar (community fork) native bridge
-keep class dev.isar.** { *; }

# just_audio / audio_service / audio_session
-keep class com.ryanheise.** { *; }

# WorkManager callbacks invoked reflectively
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.ListenableWorker
