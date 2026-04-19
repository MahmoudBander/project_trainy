import 'package:flutter/material.dart';

// --- استدعاء شاشات استعادة الحساب ---
import 'email_input_screen.dart';
import 'otp_verification_screen.dart';


class forgot_password_screen extends StatefulWidget {
  const forgot_password_screen({super.key});

  @override
  State<forgot_password_screen> createState() => _forgot_password_screenState();
}

class _forgot_password_screenState extends State<forgot_password_screen> {
  String _selectedOption = 'email';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ],
          title: const Text(
            "نسيت كلمة المرور",
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // --- الخط الفاصل بعرض الشاشة بالكامل (خارج الـ Padding) ---
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 1.5,
              color: const Color(0xFFEEEEEE),
            ),
            const SizedBox(height: 20),

            // باقي محتوى الصفحة
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    Container(
                      height: 250,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/images/email_img/amico.png",
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      "الرجاء إدخال عنوان بريدك الإلكتروني\nلتلقي رمز التحقق",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 35),

                    _buildOption(
                      id: 'email',
                      title: "المتابعة عبر البريد الإلكتروني",
                      subtitle: "بريدك الإلكتروني مرتبط بالحساب",
                      icon: Icons.alternate_email,
                    ),

                    const SizedBox(height: 15),

                    _buildOption(
                      id: 'phone',
                      title: "الاستمرار عبر الهاتف",
                      subtitle: "هاتفك مرتبط بالحساب",
                      icon: Icons.phone_android_rounded,
                    ),

                    const SizedBox(height: 40),

                    // زر الإرسال
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedOption == 'email') {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EmailInputScreen()));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const OtpVerificationScreen(title: "التحقق من رقم الهاتف")));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "ارسال",
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    bool isSelected = (_selectedOption == id);

    return GestureDetector(
      onTap: () => setState(() => _selectedOption = id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.black : Colors.grey, width: 1.5),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  height: 15,
                  width: 15,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}