import 'package:flutter/material.dart';
import 'package:project_bander/features/auth/presention/pages/reset_password_screen.dart';


class EmailInputScreen extends StatefulWidget {
  const EmailInputScreen({super.key});

  @override
  State<EmailInputScreen> createState() => _EmailInputScreenState();
}

class _EmailInputScreenState extends State<EmailInputScreen> {
  // تعريف الـ FocusNodes للتحكم في التنقل
  final FocusNode _focus1 = FocusNode();
  final FocusNode _focus2 = FocusNode();
  final FocusNode _focus3 = FocusNode();
  final FocusNode _focus4 = FocusNode();

  @override
  void dispose() {
    _focus1.dispose();
    _focus2.dispose();
    _focus3.dispose();
    _focus4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // اتجاه التطبيق العام
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ],
          title: const Text(
            "التحقق من بريدك الإلكتروني",
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // --- هذا الخط يأخذ عرض الشاشة بالكامل (خارج الـ Padding) ---
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 1.5,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),

            // باقي المحتوى داخل Expanded و ScrollView مع مسافات جانبية
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      height: 320,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/images/email_img/amico2.png",
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.mark_email_read_outlined, size: 100, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "الرجاء إدخال الرمز المكون من 4 أرقام\nالمرسل إلى example@123.gmail.com",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 50),

                    // --- ترتيب المربعات يبدأ من اليسار ---
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _otpBox(context, _focus1, nextNode: _focus2, isFirst: true),
                          _otpBox(context, _focus2, nextNode: _focus3, prevNode: _focus1),
                          _otpBox(context, _focus3, nextNode: _focus4, prevNode: _focus2),
                          _otpBox(context, _focus4, prevNode: _focus3, isLast: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // --- زر التأكيد ---
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ResetPasswordScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)
                          ),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.5),
                        ),
                        child: const Text(
                          "تأكيد",
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ميثود بناء مربع الـ OTP
  Widget _otpBox(BuildContext context, FocusNode currentNode,
      {FocusNode? nextNode, FocusNode? prevNode, bool isFirst = false, bool isLast = false}) {
    return Container(
      width: 55,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        focusNode: currentNode,
        autofocus: isFirst,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          hintText: "*",
          hintStyle: TextStyle(color: Colors.grey),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            if (!isLast && nextNode != null) {
              FocusScope.of(context).requestFocus(nextNode);
            } else if (isLast) {
              currentNode.unfocus(); // إغلاق الكيبورد
            }
          } else if (value.isEmpty) {
            if (!isFirst && prevNode != null) {
              FocusScope.of(context).requestFocus(prevNode);
            }
          }
        },
      ),
    );
  }
}