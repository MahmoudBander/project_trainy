import 'package:flutter/material.dart';
import 'dart:async';
// تأكد من أن اسم الملف login_screen.dart صحيح لديك وموجود في نفس المجلد أو المسار الصحيح
import 'login_screen.dart';

class SuccessChangePasswordScreen extends StatefulWidget {
  const SuccessChangePasswordScreen({super.key});

  @override
  State<SuccessChangePasswordScreen> createState() => _SuccessChangePasswordScreenState();
}

class _SuccessChangePasswordScreenState extends State<SuccessChangePasswordScreen> {

  @override
  void initState() {
    super.initState();
    // مؤقت زمني لمدة 5 ثوانٍ ثم الانتقال
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // استخدام pushReplacement لإزالة هذه الشاشة من السجل (Stack) نهائياً
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- أيقونة النجاح ---
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 70,
                ),
              ),

              const SizedBox(height: 40),

              // --- العنوان الرئيسي ---
              const Text(
                "تم تغيير كلمة المرور",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),

              // --- نص وصفي فرعي ---
              const Text(
                "لقد تم تحديث كلمة المرور الخاصة بك بنجاح.\nيمكنك الآن تسجيل الدخول مجدداً.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 50),
              // تم حذف دائرة التحميل من هنا بناءً على طلبك
            ],
          ),
        ),
      ),
    );
  }
}