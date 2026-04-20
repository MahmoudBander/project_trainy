import 'package:flutter/material.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:project_bander/modules/layout/data/status.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PassengerData extends StatefulWidget {
  static const route = "passengerData";
  final ApiStation  fromStation;
  final ApiStation  toStation;
  final String      departureDate;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  const PassengerData({super.key, required this.fromStation, required this.toStation, required this.departureDate, this.onNext, this.onBack});

  @override
  State<PassengerData> createState() => _PassengerDataState();
}

class _PassengerDataState extends State<PassengerData> {
  final _nameCtrl  = TextEditingController();
  final _idCtrl    = TextEditingController();
  final _birthCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final name = await SessionManager.getName() ?? '';
    if (mounted) setState(() => _nameCtrl.text = name);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _birthCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(children: [
                IconButton(
                    onPressed: () { if (widget.onBack != null) { widget.onBack!(); } else { Navigator.pop(context); } },
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black)),
                const Expanded(
                    child: Text("بيانات الركاب",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30, fontFamily: "Cairo", fontWeight: FontWeight.bold))),
                const SizedBox(width: 40),
              ]),
            ),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 70),

            buildEditableField(label: "الاسم بالكامل",  controller: _nameCtrl,
                icon: Icons.person_outline, keyboardType: TextInputType.name),
            const SizedBox(height: 60),

            buildEditableField(label: "الرقم القومي",   controller: _idCtrl,
                icon: Icons.badge_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: 60),

            buildEditableField(label: "تاريخ الميلاد",  controller: _birthCtrl,
                icon: Icons.calendar_month_outlined, hint: "DD / MM / YYYY"),

            const SizedBox(height: 45),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    // احفظ الرقم القومي
                    if (_idCtrl.text.isNotEmpty) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('national_id', _idCtrl.text.trim());
                    }
                    if (!mounted) return;
                    if (widget.onNext != null) { widget.onNext!(); } else {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => Status(
                            fromStation:   widget.fromStation,
                            toStation:     widget.toStation,
                            departureDate: widget.departureDate,
                          )));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF121212),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 8, shadowColor: Colors.black.withOpacity(0.5)),
                  child: const Text("متابعه",
                      style: TextStyle(color: Colors.white, fontSize: 22,
                          fontFamily: "Cairo", fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12, offset: const Offset(0, 8))],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(children: [
              Icon(icon, color: Colors.grey.shade400, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.right,
                  keyboardType: keyboardType,
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade700,
                      fontFamily: "Cairo", fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: const TextStyle(color: Colors.grey, fontFamily: "Cairo")),
                ),
              ),
            ]),
          ),
          Positioned(
            top: -22, right: 15,
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.white,
                child: Text(label,
                    style: const TextStyle(fontSize: 22, fontFamily: "Cairo",
                        fontWeight: FontWeight.bold, color: Colors.black))),
          ),
        ],
      ),
    );
  }
}
