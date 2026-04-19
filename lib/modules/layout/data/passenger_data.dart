import 'package:flutter/material.dart';
import 'package:project_bander/modules/layout/data/status.dart';

class PassengerData extends StatefulWidget {
  static const route = "passengerData";
  const PassengerData({super.key});

  @override
  State<PassengerData> createState() => _PassengerDataState();
}

class _PassengerDataState extends State<PassengerData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // الهيدر (العنوان وزر الرجوع)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                  ),
                  const Expanded(
                    child: Text(
                      "بيانات الركاب",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: "Cairo",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 70),

            // الحقول المطلوبة مع الظل المعدل
            buildReadOnlyField(
              label: "الاسم بالكامل",
              value: "ريم احمد محمد",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 60),

            buildReadOnlyField(
              label: "الرقم القومي",
              value: "47840677828923",
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 60),

            buildReadOnlyField(
              label: "تاريخ الميلاد",
              value: "15 \\ 03 \\ 2000",
              icon: Icons.calendar_month_outlined,
            ),

            const SizedBox(height: 45),


            // زر متابعه
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Status.route);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF121212),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8, // ظل الزرار كما في الصورة
                    shadowColor: Colors.black.withOpacity(0.5),
                  ),
                  child: const Text(
                    "متابعه",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: "Cairo",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // الويدجت المعدلة بالكامل لضبط الظل والـ Label
  Widget buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // الحاوية الأساسية مع الظل السفلي
          Container(
            width: double.infinity,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08), // درجة الشفافية للظل
                  blurRadius: 12, // مدى انتشار الظل
                  offset: const Offset(0, 8), // تحريك الظل للأسفل فقط
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey.shade400, size: 28),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade700,
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // العنوان (Label)
          Positioned(
            top: -22, // رفعه للأعلى ليقطع الخط بوضوح
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.white, // نفس لون الخلفية لإخفاء البوردر خلف النص
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 22,
                  fontFamily: "Cairo",
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}