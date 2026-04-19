import 'package:flutter/material.dart';
// تأكد من تغيير المسار التالي حسب اسم ملف شاشة النجاح عندك
import 'success_password_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // متغيرات للتحكم في إظهار أو إخفاء كلمات المرور
  bool _isObscure1 = true;
  bool _isObscure2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "انشاء كلمة مرور جديدة",
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // دعم الواجهة العربية
        child: Column(
          children: [
            // --- 3. الخط الفاصل (يمتد للحافة بدون مسافات جانبيّة) ---
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 1.5,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),

            // باقى محتوى الصفحة داخل ScrollView
            Expanded(
              child: SingleChildScrollView(
                // تم نقل الـ padding الأفقي هنا بدلاً من الـ body بالكامل
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- قسم الصورة التوضيحية (تكبير الحجم كما في الصورة) ---
                    Center(
                      child: Container(
                        height: 320,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/images/email_img/amico3.png", // تأكد من صحة مسار الصورة
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.security_rounded, size: 100, color: Colors.grey),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- حقل كلمة المرور الجديدة ---
                    const Text(
                      "كلمة المرور الجديدة",
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPasswordField(
                      hint: "أدخل كلمة المرور الجديدة",
                      isObscure: _isObscure1,
                      onToggle: () => setState(() => _isObscure1 = !_isObscure1),
                    ),

                    const SizedBox(height: 25),

                    // --- حقل تأكيد كلمة المرور ---
                    const Text(
                      "تأكيد كلمة المرور",
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPasswordField(
                      hint: "أدخل تأكيد كلمة المرور",
                      isObscure: _isObscure2,
                      onToggle: () => setState(() => _isObscure2 = !_isObscure2),
                    ),

                    const SizedBox(height: 50),

                    // --- زر الحفظ النهائي ---
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: () {
                          // تأكد من وجود الملف success_password_screen.dart
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SuccessChangePasswordScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.4),
                        ),
                        child: const Text(
                          "حفظ",
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ميثود بناء حقل كلمة المرور بتنسيق الصورة الجديد
  Widget _buildPasswordField({
    required String hint,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE), // لون رمادي فاتح جداً للخلفية
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        obscureText: isObscure, // --- 2. التحكم في إظهار النص هنا ---
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 14),

          // --- 1. تبديل الأماكن: القفل الآن على اليسار (Prefix) ---
          prefixIcon: const Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.lock_rounded, color: Colors.black, size: 22),
          ),

          // --- 1. تبديل الأماكن: العين الآن على اليمين (Suffix) ---
          suffixIcon: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              // --- 2. تغيير شكل العين حسب الحالة ---
              icon: Icon(
                isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: onToggle, // --- 2. تفعيل الضغط لتغيير الحالة ---
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}