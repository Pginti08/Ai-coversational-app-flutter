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

# Razorpay
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepattributes JavascriptInterface
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/*
-keepclasseswithmembers class * {
  public void onPayment*(...);
}