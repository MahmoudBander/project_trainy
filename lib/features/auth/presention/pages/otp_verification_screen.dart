import 'package:flutter/material.dart';
import 'dart:async';
import 'reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String title;

  const OtpVerificationScreen({super.key, required this.title});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String enteredCode = "";
  Timer? _timer;
  int _start = 40;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() => timer.cancel());
      } else {
        setState(() => _start--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _inputNumber(String number) {
    if (enteredCode.length < 4) {
      setState(() => enteredCode += number);
    }
  }

  void _deleteNumber() {
    if (enteredCode.isNotEmpty) {
      setState(() => enteredCode = enteredCode.substring(0, enteredCode.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // --- 1. الخط العلوي (بعرض الشاشة بالكامل) ---
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 1.5,
              color: Colors.grey[300],
            ),

            // محتوى الصفحة (خانات الـ OTP والزر)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        bool isFilled = index < enteredCode.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 52,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isFilled ? Colors.black : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              isFilled ? enteredCode[index] : "*",
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: isFilled ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 25),
                    GestureDetector(
                      onTap: _start == 0 ? () {
                        setState(() => _start = 40);
                        startTimer();
                      } : null,
                      child: Text(
                        _start > 0
                            ? "إعادة إرسال الرمز في $_start ثانية"
                            : "لم يصلك الرمز؟ إعادة الإرسال",
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: _start > 0 ? Colors.grey[600] : Colors.black,
                          fontWeight: _start > 0 ? FontWeight.normal : FontWeight.bold,
                          decoration: _start == 0 ? TextDecoration.underline : TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: enteredCode.length == 4 ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
                          );
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text(
                          "تأكيد",
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),

            // --- 2. الخط السفلي (بعرض الشاشة بالكامل) ---
            Container(
              width: double.infinity,
              height: 1.5,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 25),

            // لوحة المفاتيح المخصصة (ببادينج جانبي فقط للأزرار)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  _keyboardRow(["1", "2", "3"]),
                  const SizedBox(height: 12),
                  _keyboardRow(["4", "5", "6"]),
                  const SizedBox(height: 12),
                  _keyboardRow(["7", "8", "9"]),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 85),
                      _keyItem("0"),
                      _keyItem("back", isIcon: true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _keyboardRow(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.map((e) => _keyItem(e)).toList(),
    );
  }

  Widget _keyItem(String label, {bool isIcon = false}) {
    return InkWell(
      onTap: () {
        if (label == "back") {
          _deleteNumber();
        } else {
          _inputNumber(label);
        }
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 85,
        height: 53,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Center(
          child: isIcon
              ? const Icon(Icons.backspace_outlined, size: 22, color: Colors.black)
              : Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}