import 'package:flutter/material.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:project_bander/modules/layout/home.dart';
import 'login_screen.dart';

class signup_screen extends StatefulWidget {
  const signup_screen({super.key});
  @override
  State<signup_screen> createState() => _signup_screenState();
}

class _signup_screenState extends State<signup_screen> {
  bool _isPasswordHidden        = true;
  bool _isConfirmPasswordHidden = true;
  bool _isLoading               = false;
  String? _errorMessage;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose(); _lastNameCtrl.dispose();
    _emailCtrl.dispose();     _phoneCtrl.dispose();
    _passCtrl.dispose();      _confirmCtrl.dispose();
    super.dispose();
  }

  // ── تحويل أي قيمة لـ int بأمان ──────────────────────────────────────────
  int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return int.tryParse(val.toString()) ?? 0;
  }

  // ── تحويل أي قيمة لـ String بأمان ───────────────────────────────────────
  String _toStr(dynamic val, [String fallback = '']) {
    if (val == null) return fallback;
    return val.toString();
  }

  Future<void> _register() async {
    final firstName = _firstNameCtrl.text.trim();
    final lastName  = _lastNameCtrl.text.trim();
    final email     = _emailCtrl.text.trim();
    final phone     = _phoneCtrl.text.trim();
    final pass      = _passCtrl.text;
    final confirm   = _confirmCtrl.text;

    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() => _errorMessage = 'من فضلك أدخل الاسم الأول والأخير'); return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'من فضلك أدخل بريد إلكتروني صحيح'); return;
    }
    if (phone.isEmpty || phone.length < 10) {
      setState(() => _errorMessage = 'من فضلك أدخل رقم هاتف صحيح'); return;
    }
    if (pass.length < 8 ||
        !pass.contains(RegExp(r'[A-Z]')) ||
        !pass.contains(RegExp(r'[0-9]')) ||
        !pass.contains(RegExp(r'[!@#\$%^&*(),.?]'))) {
      setState(() => _errorMessage = 'كلمة المرور يجب أن تحتوي على حرف كبير ورقم ورمز\nمثال: Trainy@2025');
      return;
    }
    if (pass != confirm) {
      setState(() => _errorMessage = 'كلمتا المرور غير متطابقتين'); return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final result = await ApiService().register(
        name:     '$firstName $lastName',
        email:    email,
        password: pass,
        phone:    phone,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // استخراج الـ data بأمان كامل
        final data = result['data'];

        // الـ token ممكن يكون في أي مكان
        final String token = _toStr(
            data is Map ? (data['token'] ?? data['accessToken'] ?? data['jwt'] ?? '') : ''
        );

        if (token.isNotEmpty) {
          // تحويل كل قيمة بأمان كامل
          final int accountId = _toInt(
              data is Map ? (data['accountId'] ?? data['id'] ?? data['userId'] ?? 0) : 0
          );
          final String name = _toStr(
              data is Map ? (data['name'] ?? data['userName'] ?? data['fullName'] ?? '') : '',
              '$firstName $lastName'
          );
          final String role = _toStr(
              data is Map ? (data['role'] ?? data['userRole'] ?? data['roles'] ?? 'User') : 'User',
              'User'
          );

          await SessionManager.save(
            token:     token,
            accountId: accountId,
            name:      name.isEmpty ? '$firstName $lastName' : name,
            role:      role.isEmpty ? 'User' : role,
            email:     email,
            phone:     phone,
          );
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
              context, Home.route, (r) => false, arguments: 4);
        } else {
          // تم التسجيل بنجاح بس مفيش token — روح للـ login
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم إنشاء الحساب بنجاح! سجل دخولك الآن."),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } else {
        // عرض رسالة الخطأ من الـ server
        String errMsg = _toStr(result['message'], 'فشل إنشاء الحساب');
        final errData = result['data'];
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
      // عرض الـ error الكامل للـ debugging
      if (mounted) {
        setState(() => _errorMessage = 'خطأ: $e');
        debugPrint('SIGNUP ERROR: $e\n$stack');
      }
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
              height: 130,
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
                    children: [
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(child: _buildFieldLabel("الاسم الأول")),
                        const SizedBox(width: 15),
                        Expanded(child: _buildFieldLabel("الاسم الأخير")),
                      ]),
                      Row(children: [
                        Expanded(child: _buildSmallInput("الاسم الأول", _firstNameCtrl)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildSmallInput("الاسم الأخير", _lastNameCtrl)),
                      ]),
                      const SizedBox(height: 15),
                      _buildFieldLabel("البريد الالكتروني"),
                      _buildFullInput(hint: "ادخل بريدك الالكتروني", icon: Icons.email,
                          keyboardType: TextInputType.emailAddress, controller: _emailCtrl),
                      const SizedBox(height: 15),
                      _buildFieldLabel("رقم الهاتف"),
                      _buildFullInput(hint: "ادخل رقم هاتفك", icon: Icons.phone_android,
                          keyboardType: TextInputType.phone, controller: _phoneCtrl),
                      const SizedBox(height: 15),
                      _buildFieldLabel("كلمة المرور"),
                      _buildFullInput(hint: "مثال: Trainy@2025", icon: Icons.lock,
                          isPass: true, isHidden: _isPasswordHidden,
                          onToggle: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                          controller: _passCtrl),
                      const SizedBox(height: 15),
                      _buildFieldLabel("تأكيد كلمة المرور"),
                      _buildFullInput(hint: "ادخل تأكيد المرور", icon: Icons.lock,
                          isPass: true, isHidden: _isConfirmPasswordHidden,
                          onToggle: () => setState(() => _isConfirmPasswordHidden = !_isConfirmPasswordHidden),
                          controller: _confirmCtrl),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "كلمة المرور يجب أن تحتوي على:\n• 8 أحرف على الأقل\n• حرف كبير (A-Z)\n• رقم (0-9)\n• رمز خاص مثل @ أو #",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.blue),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
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
                      ],
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("انشاء حساب",
                              style: TextStyle(fontFamily: 'Cairo', color: Colors.white,
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "بالتسجيل، فإنك توافق على سياسة الاستخدام وإشعار الخصوصية.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                            color: Color(0xff383434), fontWeight: FontWeight.w500),
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

  Widget _buildFieldLabel(String label) => Align(
    alignment: Alignment.centerRight,
    child: Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 5),
      child: Text(label,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700)),
    ),
  );

  Widget _buildSmallInput(String hint, TextEditingController controller) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      color: const Color(0xFFEEEEEE),
      borderRadius: BorderRadius.circular(25),
    ),
    child: TextField(
      controller: controller,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey),
      ),
    ),
  );

  Widget _buildFullInput({
    required String hint,
    required IconData icon,
    bool isPass = false,
    bool? isHidden,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
    required TextEditingController controller,
  }) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFEEEEEE),
      borderRadius: BorderRadius.circular(30),
    ),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPass ? (isHidden ?? true) : false,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 15, color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.black),
        suffixIcon: isPass
            ? IconButton(
            icon: Icon((isHidden ?? true) ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey),
            onPressed: onToggle)
            : null,
      ),
    ),
  );
}
