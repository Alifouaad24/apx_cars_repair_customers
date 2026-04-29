# ===== ML Kit (حل نهائي) =====

-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Text Recognition (جميع اللغات)
-keep class com.google.mlkit.vision.text.** { *; }

# مهم جداً (المشكلة عندك هنا)
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }

# Google Play services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# منع R8 من حذف الـ annotations
-keepattributes *Annotation*