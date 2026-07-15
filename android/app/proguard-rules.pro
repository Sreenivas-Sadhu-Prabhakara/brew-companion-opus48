# Flutter core — keep the embedding + plugin registrant.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep annotations and native method bindings.
-keepattributes *Annotation*
-keepclasseswithmembernames class * {
    native <methods>;
}

# shared_preferences uses platform channels; nothing to strip aggressively.
-dontwarn io.flutter.embedding.**
