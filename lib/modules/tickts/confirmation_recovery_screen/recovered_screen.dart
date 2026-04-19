import 'dart:async'; // مكتبة التوقيت
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../layout/home.dart';

class Recoveredscreen extends StatefulWidget {
  const Recoveredscreen({super.key});

  @override
  State<Recoveredscreen> createState() => _RecoveredscreenState();
}

class _RecoveredscreenState extends State<Recoveredscreen> {
  @override
  void initState() {
    super.initState();

    // إعداد المؤقت الزمني: 3 ثوانٍ ثم الانتقال
    Timer(const Duration(seconds: 3), () {
      // نستخدم pushReplacement لمنع المستخدم من العودة لهذه الصفحة مرة أخرى عند الضغط على زر الرجوع
      // تأكد من استبدال اسم الصفحة (HomeScreen) بالاسم الفعلي لصفحة البداية عندك
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Home.route,
              (route) => false, // بيمسح الصفحات اللي فاتت عشان يظهر البوتوم بار كأنك لسه داخل
          arguments: 4,     // رقم 3 هو الـ Index بتاع صفحة "تذاكري" في الـ list بتاعتك
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // تصميم الأيقونة واللوجو في المنتصف
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/icons/5965208742762581546.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Image.asset(
                "assets/images/icons/5965208742762581545.jpg",
                width: 50,
                height: 50,
              ),
            ),

            const SizedBox(height: 30),

            // نص النجاح
            Text(
              "تم ارسال طلب الاسترداد بنجاح!",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            // نص التوضيح
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "سيتم مراجعه الطلب وابلاغك بحالة الاسترداد قريبا.",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // تم حذف دائرة التحميل (CircularProgressIndicator) بناءً على طلبك
          ],
        ),
      ),
    );
  }
}