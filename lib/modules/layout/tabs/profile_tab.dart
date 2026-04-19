import 'package:flutter/material.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:project_bander/features/auth/presention/pages/login_screen.dart';
import 'package:project_bander/modules/layout/tabs/setting/help_center_screen.dart';
import 'package:project_bander/modules/layout/tabs/setting/settings_screen.dart';
import '../../../core/theme/app_color.dart';
import '../../widget/row_widget.dart';
import 'home_tab.dart';

class ProfileTab extends StatefulWidget {
  static const route = "profile";
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _name  = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name  = await SessionManager.getName()  ?? '';
    final email = await SessionManager.getEmail() ?? '';
    if (mounted) setState(() { _name = name; _email = email; });
  }

  Future<void> _logout() async {
    await SessionManager.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 89, 0, 0),
            child: IconButton(
              onPressed: () => Navigator.pushReplacementNamed(context, HomeTab.route),
              icon: const Icon(Icons.chevron_left, size: 40))),
          Padding(
            padding: const EdgeInsets.fromLTRB(70, 85, 50, 0),
            child: const Text("الملف الشخصي",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, fontFamily: "Cairo"))),
        ]),
        const SizedBox(height: 20),
        Container(height: 2, width: double.infinity, color: AppColor.grey),
        const SizedBox(height: 20),
        Stack(children: [
          ClipOval(
            child: Image.asset("assets/images/onboarding_img/bander.jpg",
              width: 120, height: 120, fit: BoxFit.cover)),
        ]),
        const SizedBox(height: 20),
        Text(_name.isNotEmpty ? _name : 'المستخدم',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        Text(_email.isNotEmpty ? _email : '',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
          child: Container(height: 2, width: double.infinity, color: AppColor.grey)),
        RowWidget(onTap: () {}, title: "مدير كلمة المرور", icon: Icons.lock),
        const SizedBox(height: 10),
        RowWidget(
          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SettingsScreen())),
          title: "إعدادات", icon: Icons.settings),
        const SizedBox(height: 10),
        RowWidget(
          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HelpCenterScreen())),
          title: "مركز المساعدة", icon: Icons.help),
        const SizedBox(height: 10),
        RowWidget(onTap: _logout, title: "تسجيل الخروج", icon: Icons.logout_outlined),
      ],
    );
  }
}
