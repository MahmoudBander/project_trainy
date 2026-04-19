import 'package:flutter/material.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:project_bander/features/auth/presention/pages/login_screen.dart';
import '../../../core/theme/app_color.dart';
import '../../layout/home.dart';

class MyCustomDrawer extends StatefulWidget {
  @override
  State<MyCustomDrawer> createState() => _MyCustomDrawerState();
}

class _MyCustomDrawerState extends State<MyCustomDrawer> {
  String _name  = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name  = await SessionManager.getName()  ?? '';
    final phone = await SessionManager.getPhone() ?? '';
    final email = await SessionManager.getEmail() ?? '';
    if (mounted) setState(() {
      _name  = name.isNotEmpty ? name : 'المستخدم';
      _phone = phone.isNotEmpty ? phone : email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── الجزء العلوي الأسود ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.only(top: 60, right: 40, bottom: 20),
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage('assets/images/onboarding_img/bander.jpg'),
                    ),
                    const SizedBox(height: 15),
                    Text(_name,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 24,
                            fontWeight: FontWeight.w700, fontFamily: "Cairo")),
                    const SizedBox(height: 5),
                    Text(_phone,
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 14,
                            fontWeight: FontWeight.w500, fontFamily: "Cairo")),
                  ],
                ),
              ),
            ),

            // ── قسم الحسابات ─────────────────────────────────────────────
            const SizedBox(height: 10),
            ListTile(
              leading: Stack(children: [
                const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/images/onboarding_img/bander.jpg')),
                Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.check_circle, color: Colors.green, size: 16))),
              ]),
              title: Text(_name,
                  style: const TextStyle(fontSize: 24,
                      fontWeight: FontWeight.w700, fontFamily: "Cairo")),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.add, color: Color(0xff817c7c)),
              title: const Text("اضافة حساب",
                  style: TextStyle(color: Color(0xff817c7c), fontSize: 16,
                      fontWeight: FontWeight.w600, fontFamily: "Cairo")),
              onTap: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => LoginScreen())),
            ),

            const Divider(thickness: 1, color: Color(0xffc2bcbc)),

            // ── قائمة التنقل ─────────────────────────────────────────────
            _buildDrawerItem(
                icon: Icons.account_circle_outlined, title: "الملف الشخصي",
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, Home.route, (route) => false, arguments: 0)),
            _buildDrawerItem(
                icon: Icons.notifications_outlined, title: "الاشعارات",
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, Home.route, (route) => false, arguments: 1)),
            _buildDrawerItem(icon: Icons.help_center, title: "مساعدة", onTap: () {}),
            _buildDrawerItem(icon: Icons.settings,    title: "الاعدادات", onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xff605e5e)),
      title: Text(title,
          style: const TextStyle(color: Color(0xff605e5e), fontSize: 16,
              fontWeight: FontWeight.w600, fontFamily: "Cairo")),
      onTap: onTap,
    );
  }
}
