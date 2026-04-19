import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/modules/tickts/confirm_payment.dart';

class PaymentScreen extends StatefulWidget {
  final double       totalPrice;
  final int          journeyId;
  final List<String> selectedSeats;

  const PaymentScreen({
    super.key,
    required this.totalPrice,
    required this.journeyId,
    required this.selectedSeats,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selectedPaymentMethod = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.black,
              ),
              Expanded(
                child: Container(width: double.infinity, color: Colors.white),
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 120),
                  Text(
                    "الدفع",
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 32,
            right: 32,
            bottom: 40,
            child: SingleChildScrollView( // أضفت سكرول بسيط لضمان عدم حدوث Overflow
              child: Column(
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "اختر طريقة الدفع",
                            style: GoogleFonts.cairo(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 50),
                          _buildPaymentMethod(0, Icons.credit_card, "بطاقة ائتمان"),
                          const SizedBox(height: 50),
                          _buildPaymentMethod(1, Icons.paypal, "PayPal"),
                          const SizedBox(height: 50),
                          _buildPaymentMethod(2, Icons.account_balance_wallet, "المحفظه الإلكترونية"),
                          const SizedBox(height: 50),
                          _buildPaymentMethod(3, Icons.attach_money_outlined, "نقدا في المحطة"),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 2. عرض السعر المستلم ديناميكياً
                      Text(
                        "${widget.totalPrice.toStringAsFixed(0)} ج.م",
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "السعر الاجمالي ",
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 65),
                  SizedBox(
                    width: double.infinity,
                    height: 72,
                    child: ElevatedButton(
                      onPressed: () {
                        String method = "";
                        switch (selectedPaymentMethod) {
                          case 0: method = "بطاقة ائتمان"; break;
                          case 1: method = "PayPal"; break;
                          case 2: method = "المحفظه الإلكترونية"; break;
                          case 3: method = "نقدا في المحطة"; break;
                        }
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) => ConfirmPayment(
                            paymentMethod: method,
                            journeyId:     widget.journeyId,
                            selectedSeats: widget.selectedSeats,
                            totalPrice:    widget.totalPrice,
                          )));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("تم اختيار: $method بمبلغ ${widget.totalPrice}"),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(59),
                        ),
                      ),
                      child: Text(
                        "متابعه",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ويدجيت مساعد لبناء طرق الدفع لتقليل تكرار الكود
  Widget _buildPaymentMethod(int index, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = index;
        });
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Icon(
            selectedPaymentMethod == index
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: selectedPaymentMethod == index
                ? Colors.black
                : Colors.black54,
            size: 35,
          ),
        ],
      ),
    );
  }
}