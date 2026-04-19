import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/core/session_manager.dart';
import '../../../core/theme/app_color.dart';
import '../home.dart';

class Veriflcation extends StatefulWidget {
  static const route = "Veriflcation";
  final String category; // "Child" | "Senior" | "Military" | "Disabled"

  const Veriflcation({super.key, this.category = ''});

  @override
  State<Veriflcation> createState() => _VeriflcationState();
}

class _VeriflcationState extends State<Veriflcation> {
  File?  _selectedImage;
  bool   _isLoading  = false;
  String _docNumber  = '';
  final  _docCtrl    = TextEditingController();

  @override
  void dispose() { _docCtrl.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  Future<void> _submit() async {
    final docNumber = _docCtrl.text.trim();
    if (docNumber.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("من فضلك أدخل الرقم القومي أو ارفع مستند")));
      return;
    }

    setState(() => _isLoading = true);
    final accountId = await SessionManager.getAccountId() ?? 0;

    final result = await ApiService().applyForDiscount(
      accountId:      accountId,
      userCategory:   widget.category.isNotEmpty ? widget.category : 'Child',
      documentNumber: docNumber.isNotEmpty ? docNumber : 'document_uploaded',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تقديم طلب الخصم بنجاح! سيتم مراجعته."),
          backgroundColor: Colors.green));
      // بعد النجاح روح للهوم
      Navigator.pushNamedAndRemoveUntil(context, Home.route, (r) => false, arguments: 4);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'فشل تقديم الطلب'),
          backgroundColor: Colors.red));
    }
  }

  String _categoryLabel() {
    switch (widget.category) {
      case 'Child':    return 'تذاكر الأطفال (خصم 50%)';
      case 'Senior':   return 'كبار السن (خصم 50%)';
      case 'Military': return 'مجند بالخدمة العسكرية (مجاني)';
      case 'Disabled': return 'من ذوي الاحتياجات الخاصة (مجاني)';
      default:         return 'خصم خاص';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Center(
                child: Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 1, offset: const Offset(1, 5))],
                    border: Border.all(color: Colors.grey.shade50),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("خدمة الحصول علي خصم",
                              style: const TextStyle(color: Color(0xff515050), fontWeight: FontWeight.w700,
                                fontSize: 24, fontFamily: "Cairo"))),
                          const Icon(Icons.check_box, size: 30),
                        ]),

                        // ── الفئة المختارة ────────────────────────────────
                        if (widget.category.isNotEmpty)
                          Container(
                            width: double.infinity, margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black, borderRadius: BorderRadius.circular(10)),
                            child: Text(_categoryLabel(),
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.white, fontFamily: "Cairo",
                                fontSize: 16, fontWeight: FontWeight.w600))),

                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                            const Text("اثبات الاستحقاق",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22, fontFamily: "Cairo")),
                          ])),

                        // ── رفع مستند ─────────────────────────────────────
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity, height: 65,
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade300)),
                            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                              Text(_selectedImage != null ? "تم اختيار الصورة ✓" : "ادخال مستند رسمي",
                                style: TextStyle(fontSize: 18, fontFamily: "Cairo",
                                  color: _selectedImage != null ? Colors.green : Colors.grey)),
                              const SizedBox(width: 15),
                              Icon(Icons.edit_note_outlined, color: Colors.grey.shade600, size: 30),
                            ]),
                          ),
                        ),

                        if (_selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(_selectedImage!, height: 80, width: double.infinity, fit: BoxFit.cover))),

                        const Text("او", style: TextStyle(fontFamily: "Cairo", fontSize: 20, fontWeight: FontWeight.w400)),

                        // ── الرقم القومي ──────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: TextFormField(
                            controller: _docCtrl,
                            onChanged: (v) => _docNumber = v,
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "ادخال الرقم القومي",
                              hintStyle: const TextStyle(color: Colors.grey, fontFamily: "Cairo"),
                              filled: true, fillColor: const Color(0xFFF5F5F5),
                              suffixIcon: const Icon(Icons.badge_outlined, color: Colors.grey),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
                            ),
                          ),
                        ),

                        const Text(".سيتم مراجعة الطلب قبل تأكيد الحجز",
                          style: TextStyle(fontFamily: "Cairo", fontSize: 16,
                            fontWeight: FontWeight.w400, color: Color(0xff7c7a7a))),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF121212),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("تقديم الطلب",
                          style: TextStyle(color: Colors.white, fontSize: 20,
                            fontFamily: "Cairo", fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
