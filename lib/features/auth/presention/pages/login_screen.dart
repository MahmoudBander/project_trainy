import 'package:flutter/material.dart';
import 'package:project_bander/modules/layout/home.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:project_bander/api/api_handler.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordHidden = true;
  bool _isLoading        = false;
  String? _errorMessage;

  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // تحويل آمن لأي نوع
  int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  String _toStr(dynamic val, [String fallback = '']) {
    if (val == null) return fallback;
    return val.toString();
  }

  Future<void> _login() async {
    final email    = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'من فضلك أدخل البريد الإلكتروني وكلمة المرور');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final result = await ApiService().login(email: email, password: password);

      if (!mounted) return;


      if (result['success'] == true) {
        final data = result['data'];

        // الـ server ممكن يرجع String أو Object
        if (data is String) {
          // الـ server رجع رسالة نصية — نبحث عن الـ accountId من التذاكر
          setState(() => _errorMessage = 'جاري البحث عن حسابك...');
          int foundId = 0;
          for (int i = 1; i <= 300; i++) {
            try {
              final tickets = await ApiService().myTickets(i);
              if (tickets['success'] == true && tickets['data'] != null) {
                final d = tickets['data'];
                if ((d is List && d.isNotEmpty) || (d is Map)) {
                  foundId = i;
                  break;
                }
              }
            } catch (_) {}
          }
          if (mounted) setState(() => _errorMessage = null);
          // حافظ على الاسم المحفوظ من الـ signup لو موجود
          final existingName = await SessionManager.getName() ?? '';
          final Map<String, String> knownNames = {
            'mb.trainy2029@gmail.com': 'Mahmoud Bander',
          };
          final Map<String, String> knownPhones = {
            'mb.trainy2029@gmail.com': '+20 1119361863',
          };
          String realName  = knownNames[email]  ?? (existingName.isNotEmpty ? existingName : '');
          final  realPhone = knownPhones[email] ?? await SessionManager.getPhone() ?? '';

          // لو مفيش اسم محفوظ — نسأل المستخدم
          if (realName.isEmpty && mounted) {
            final nameController = TextEditingController();
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('ادخل اسمك', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                content: TextField(
                  controller: nameController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                      hintText: 'الاسم الأول والاسم الأخير',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      child: const Text('حفظ', style: TextStyle(color: Colors.white, fontFamily: 'Cairo'))),
                ],
              ),
            );
            realName = nameController.text.trim().isNotEmpty
                ? nameController.text.trim()
                : email.split('@')[0];
          }

          await SessionManager.save(
            token:     'local_session_${DateTime.now().millisecondsSinceEpoch}',
            accountId: foundId,
            name:      realName,
            role:      'User',
            email:     email,
            phone:     realPhone,
          );
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
              context, Home.route, (route) => false, arguments: 4);
          return;
        }

        final String token = _toStr(
            data is Map ? (data['token'] ?? data['accessToken'] ?? data['jwt'] ?? '') : ''
        );

        if (token.isEmpty) {
          setState(() => _errorMessage = 'خطأ: لم يُرجع الخادم token');
          return;
        }

        final int accountId = _toInt(
            data is Map ? (data['accountId'] ?? data['id'] ?? data['userId'] ?? 0) : 0
        );
        final String name = _toStr(
            data is Map ? (data['name'] ?? data['userName'] ?? data['fullName'] ?? '') : '',
            ''
        );
        final String role = _toStr(
            data is Map ? (data['role'] ?? data['userRole'] ?? 'User') : 'User',
            'User'
        );

        await SessionManager.save(
          token:     token,
          accountId: accountId,
          name:      name,
          role:      role,
          email:     email,
        );

        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
            context, Home.route, (route) => false, arguments: 4);
      } else {
        final errData = result['data'];
        String errMsg = _toStr(result['message'], 'فشل تسجيل الدخول');
        if (errData is Map) {
          final errors = errData['errors'];
          if (errors is Map) {
            errMsg = errors.values
                .expand((v) => v is List ? v.map((e) => e.toString()) : [v.toString()])
                .join('\n');
          } else if (errData['message'] != null) {
            errMsg = _toStr(errData['message']);
          }
        }
        setState(() => _errorMessage = errMsg);
      }
    } catch (e, stack) {
      debugPrint('LOGIN ERROR: $e\n$stack');
      if (mounted) setState(() => _errorMessage = 'خطأ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Container(
              height: 150,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("قطاري – Trainy",
                      style: TextStyle(fontFamily: 'Cairo', color: Colors.white,
                          fontSize: 32, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 15),
                  Image.asset("assets/images/logo_img/ion_train-sharp.png", height: 45),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("تسجيل الدخول",
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 32, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 30),
                      _buildInputLabel("البريد الالكتروني"),
                      _buildInputField(hint: "ادخل بريدك الالكتروني",
                          icon: Icons.email, isPass: false, controller: _emailCtrl),
                      const SizedBox(height: 20),
                      _buildInputLabel("كلمة المرور"),
                      _buildInputField(hint: "ادخل كلمة المرور",
                          icon: Icons.lock, isPass: true, controller: _passCtrl),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const forgot_password_screen())),
                          child: const Text("هل نسيت كلمة المرور؟",
                              style: TextStyle(fontFamily: 'Cairo', color: Colors.indigo,
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(_errorMessage!,
                              style: const TextStyle(fontFamily: 'Cairo', color: Colors.red, fontSize: 13),
                              textAlign: TextAlign.right),
                        ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35)),
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("متابعة",
                              style: TextStyle(fontFamily: 'Cairo', color: Colors.white,
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _dividerWithContainers(),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialIcon("assets/images/icons/facebook.png"),
                          const SizedBox(width: 20),
                          _socialIcon("assets/images/icons/google.png"),
                          const SizedBox(width: 20),
                          _socialIcon("assets/images/icons/instagram.png"),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("ليس لديك حساب؟ ",
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 14)),
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const signup_screen())),
                            child: const Text("انشاء حساب",
                                style: TextStyle(fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) => Align(
    alignment: Alignment.centerRight,
    child: Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 5),
      child: Text(text,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 24, fontWeight: FontWeight.w500)),
    ),
  );

  Widget _buildInputField({required String hint, required IconData icon,
    bool isPass = false, required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass ? _isPasswordHidden : false,
        keyboardType: isPass ? TextInputType.visiblePassword : TextInputType.emailAddress,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 15),
          prefixIcon: Icon(icon, color: Colors.black),
          suffixIcon: isPass
              ? IconButton(
              icon: Icon(_isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey),
              onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden))
              : null,
        ),
      ),
    );
  }

  Widget _dividerWithContainers() => Row(children: [
    Expanded(child: Container(height: 1.2,
        margin: const EdgeInsets.only(left: 15, right: 10), color: const Color(0xffd9d9d9))),
    const Text("او سجل باستخدام",
        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700,
            fontSize: 18, color: Colors.black)),
    Expanded(child: Container(height: 1.2,
        margin: const EdgeInsets.only(left: 10, right: 15), color: const Color(0xffd9d9d9))),
  ]);

  Widget _socialIcon(String imagePath) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Image.asset(imagePath, width: 35, height: 35),
  );
}
