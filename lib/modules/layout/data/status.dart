import 'package:flutter/material.dart';
import 'package:project_bander/modules/layout/data/veriflcation.dart';
import '../../../core/theme/app_color.dart';
import '../../widget/card_status.dart';
import '../home.dart';

class Status extends StatefulWidget {
  static const route = "Status";
  const Status({super.key});

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  // الفئة المختارة — تتبعت للـ API
  String? selectedCategory; // "Child" | "Senior" | "Military" | "Disabled"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, Home.route),
                  child: const Text("تخطي",
                    style: TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.w700, fontFamily: "Cairo"))),
              ),
            ]),
            const SizedBox(height: 20),
            const Text("هل انت مؤهل الحصول علي خصم ؟",
              style: TextStyle(fontFamily: "Cairo", fontSize: 24, fontWeight: FontWeight.w700)),
            const Text("بعض الفئات تحصل علي تخفيضات خاصه علي التذاكر",
              style: TextStyle(fontFamily: "Cairo", fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey)),
            const SizedBox(height: 20),

            // ── كل كارت بيبعت الـ category للـ Veriflcation ────────────────
            CardStatus(
              status:   "تذاكر الاطفال",
              detals:   "خصم يصل ل 50% | الاطفال دون 16 سنة",
              category: "Child",
              selected: selectedCategory == "Child",
              onTap:    () => setState(() => selectedCategory = "Child"),
            ),
            CardStatus(
              status:   "كبار السن",
              detals:   "خصم يصل ل50%  لمن هم فوق 60 سنه",
              category: "Senior",
              selected: selectedCategory == "Senior",
              onTap:    () => setState(() => selectedCategory = "Senior"),
            ),
            CardStatus(
              status:   "مجند بالخدمة العسكرية",
              detals:   "التذكرة مجانية",
              category: "Military",
              selected: selectedCategory == "Military",
              onTap:    () => setState(() => selectedCategory = "Military"),
            ),
            CardStatus(
              status:   "من ذوي الاحتياجات الخاصة",
              detals:   "التذكرة مجانية",
              category: "Disabled",
              selected: selectedCategory == "Disabled",
              onTap:    () => setState(() => selectedCategory = "Disabled"),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("من فضلك اختر فئة أولاً")));
                      return;
                    }
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => Veriflcation(category: selectedCategory!)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF121212),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5),
                  child: const Text("متابعه",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: "Cairo", fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
