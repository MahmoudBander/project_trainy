import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/features/auth/presention/pages/login_screen.dart';

import '../../home.dart';


class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            color: Colors.white,
            child: Stack(
              children: [
                Positioned(
                  left: 16,
                  bottom: 35,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Home.route,
                            (route) => false, // بيمسح الصفحات اللي فاتت عشان يظهر البوتوم بار كأنك لسه داخل
                        arguments: 0,     // رقم 3 هو الـ Index بتاع صفحة "تذاكري" في الـ list بتاعتك
                      );
                    },
                    icon: Icon(Icons.chevron_left),
                    iconSize: 24,
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 40,
                  child: Center(
                    child: Text(
                      'الاعدادات',
                      style: GoogleFonts.cairo(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, width: double.infinity, color: Colors.grey[300]),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "التفضيلات",
                          style: GoogleFonts.cairo(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.chevron_left),
                        ),
                        Text(
                          "ادارة الحساب",
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.chevron_left),
                        ),
                        Text(
                          "التحقق من الخصوصية",
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              Home.route,
                                  (route) => false, // بيمسح الصفحات اللي فاتت عشان يظهر البوتوم بار كأنك لسه داخل
                              arguments: 2,     // رقم 3 هو الـ Index بتاع صفحة "تذاكري" في الـ list بتاعتك
                            );
                          },
                          icon: Icon(Icons.chevron_left),
                        ),
                        Text(
                          "الاشتراكات",
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              Home.route,
                                  (route) => false, // بيمسح الصفحات اللي فاتت عشان يظهر البوتوم بار كأنك لسه داخل
                              arguments: 1,     // رقم 3 هو الـ Index بتاع صفحة "تذاكري" في الـ list بتاعتك
                            );
                          },
                          icon: Icon(Icons.chevron_left),
                        ),
                        Text(
                          "الاشعارات",
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          },
                          icon: Icon(Icons.chevron_left),
                        ),
                        Text(
                          "اضافة حساب",
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.chevron_left),
                        ),
                        Text(
                          "الامان",
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          },
                          icon: Icon(Icons.chevron_left),
                        ),
                        Text(
                          "تسجيل الخروج",
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
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
    );
  }
}
