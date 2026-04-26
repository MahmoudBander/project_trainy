import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../home.dart';

class HelpCenterScreen extends StatelessWidget {
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
                      'مركز المساعدة ',
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
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.chevron_left),
                        ),
                        Text(
                          "شروط الخدمة",
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.chevron_left),
                        ),
                        Text(
                          "سياسة الخصوصية",
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.chevron_left),
                        ),
                        Text(
                          "معلومات حول",
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
