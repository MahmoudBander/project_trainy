import 'package:flutter/material.dart';

import '../../core/theme/app_color.dart';

class RowWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap; // القيمة اللي هتتغير مع كل استدعاء

  const RowWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap, // لازم نطلبه هنا
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
          child: IconButton(
            onPressed: onTap, // هنا بنستخدم الدالة اللي بعتناها
            icon: const Icon(Icons.chevron_left, size: 40),
          ),
        ),
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 30,
                fontFamily: "Cairo",
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                  // تصحيح بسيط: BoxBorder.all تتكتب Border.all
                  border: Border.all(color: AppColor.grey),
                  borderRadius: BorderRadius.circular(25),
                  color: AppColor.grey,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(icon, size: 24), // استخدم size بدل weight للأيقونة
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}