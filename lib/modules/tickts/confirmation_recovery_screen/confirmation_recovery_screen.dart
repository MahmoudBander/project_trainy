import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/modules/tickts/confirmation_recovery_screen/recovered_screen.dart';


class ConfirmationRecoveryScreen extends StatefulWidget {
  @override
  State<ConfirmationRecoveryScreen> createState() =>
      _ConfirmationRecoveryScreenState();
}

class _ConfirmationRecoveryScreenState
    extends State<ConfirmationRecoveryScreen> {
  bool _isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                color: Colors.white,
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      bottom: 30,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back),
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
                          'حالة استرداد الاموال ',
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey[300],
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.yellowAccent,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'معلق',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xffBD910D),
                                ),
                              ),
                            ),
                            SizedBox(width: 80),
                            Text(
                              '120541#',
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "طلب استرداد ",
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "CAI-ALX-98765",
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(width: 100),
                                    Text(
                                      " : تذكرة رقم",
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "اكتوبر 2025 28",
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(width: 100),
                                    Text(
                                      " : تاريخ الرحلة",
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "300.00 ج.م",
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(width: 75),
                                    Text(
                                      " : المبلغ المسترد",
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "تنبيه",
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.warning, color: Colors.yellowAccent),
                          ],
                        ),
                        SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "قد يتم خصم رسوم ادارية حسب سياسة الاسترداد",
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "أوافق على سياسة الاسترداد",
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 10),
                            Transform.scale(
                              scale: 1.5,
                              child: Checkbox(
                                value: _isChecked,
                                activeColor: Colors.black,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _isChecked = newValue ?? false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 68,
                          child: ElevatedButton(
                            onPressed: _isChecked
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Recoveredscreen(),
                                ),
                              );
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isChecked
                                  ? Colors.black
                                  : Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(59),
                              ),
                            ),
                            child: Text(
                              "تأكيد طلب الاسترداد",
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                color: _isChecked ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 68,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 10,
                              shadowColor: Colors.black.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(59),
                              ),
                            ),
                            child: Text(
                              "الغاء",
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
