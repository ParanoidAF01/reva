# Keep rules for Razorpay and other missing classes
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }
# Add other keep rules as needed for plugins using reflection or dynamic loading
