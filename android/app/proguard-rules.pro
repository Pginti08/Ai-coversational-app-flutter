# UCrop (Image Cropper) dependencies
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**

# OkHttp3 (The missing classes)
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**

# If you use Okio (often bundled with OkHttp)
-keep class okio.** { *; }
-dontwarn okio.**