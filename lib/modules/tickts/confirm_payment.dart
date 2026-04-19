import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:project_bander/modules/tickts/booked_screen.dart';

class ConfirmPayment extends StatefulWidget {
  final String?      paymentMethod;
  final int          journeyId;
  final List<String> selectedSeats;
  final double       totalPrice;

  const ConfirmPayment({
    Key? key,
    this.paymentMethod,
    required this.journeyId,
    required this.selectedSeats,
    required this.totalPrice,
  }) : super(key: key);

  @override
  _ConfirmPaymentState createState() => _ConfirmPaymentState();
}

class _ConfirmPaymentState extends State<ConfirmPayment> {
  final _cardNumberController  = TextEditingController(text: "13458757654309765");
  final _cardHolderController  = TextEditingController(text: "ادخل الاسم كما هو علي البطاقة");
  final _expiryDateController  = TextEditingController(text: "MM / YY");
  final _cvcController         = TextEditingController(text: "123");

  bool    _isLoading    = false;
  String? _errorMessage;

  @override
  void dispose() {
    _cardNumberController.dispose(); _cardHolderController.dispose();
    _expiryDateController.dispose(); _cvcController.dispose();
    super.dispose();
  }

  // ── الخطوتين: CreateTicket ثم Payment ────────────────────────────────────
  Future<void> _confirmPayment() async {
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final accountId = await SessionManager.getAccountId() ?? 0;
      final api       = ApiService();

      final List<int> createdTicketIds = [];

      // لو الـ journeyId = 0 يعني رحلة وهمية — نروح مباشرة لشاشة النجاح
      if (widget.journeyId == 0) {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => BookedScreen(ticketIds: [1, 2, 3])));
        return;
      }

      for (final seatStr in widget.selectedSeats) {
        final seatNumber = int.tryParse(seatStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
        final bookResult = await api.createTicket(
          journeyId:  widget.journeyId,
          seatNumber: seatNumber,
          accountId:  accountId,
        );
        if (bookResult['success'] != true) {
          setState(() { _isLoading = false; _errorMessage = bookResult['message'] ?? 'فشل حجز المقعد $seatStr'; });
          return;
        }
        final ticketId = bookResult['data']?['ticketId'] ?? bookResult['data']?['id'];
        if (ticketId != null) createdTicketIds.add(ticketId);
      }

      for (final ticketId in createdTicketIds) {
        final payResult = await api.payTicket(ticketId);
        if (payResult['success'] != true) {
          setState(() { _isLoading = false; _errorMessage = payResult['message'] ?? 'فشل الدفع'; });
          return;
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => BookedScreen(ticketIds: createdTicketIds)));

    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _errorMessage = 'حدث خطأ، تحقق من الاتصال'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(children: [
            Container(height: 200, width: double.infinity, color: Colors.black),
            Expanded(child: Container(width: double.infinity, color: Colors.white)),
          ]),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 85),
                Text("بيانات الدفع",
                    style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                const Spacer(),
              ]),
            ),
          ),
          Positioned(
            top: 150, left: 10, right: 10, bottom: 40,
            child: SingleChildScrollView(
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
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                          // ── عنوان ─────────────────────────────────────────
                          Row(children: [
                            const Icon(Icons.payment_rounded, color: Colors.black, size: 35),
                            const SizedBox(width: 12),
                            Text("بيانات بطاقة الائتمان",
                                style: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w700)),
                          ]),
                          const SizedBox(height: 20),

                          // ── رقم البطاقة ───────────────────────────────────
                          _fieldLabel("رقم البطاقة"),
                          const SizedBox(height: 15),
                          _cardField(
                            controller: _cardNumberController,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.credit_card_rounded,
                            placeholder: "13458757654309765",
                            hasVisaLogo: true,
                          ),
                          const SizedBox(height: 15),

                          // ── اسم صاحب البطاقة ──────────────────────────────
                          _fieldLabel("اسم صاحب البطاقة"),
                          const SizedBox(height: 15),
                          _cardField(
                            controller: _cardHolderController,
                            keyboardType: TextInputType.text,
                            prefixIcon: Icons.person,
                            placeholder: "ادخل الاسم كما هو علي البطاقة",
                          ),
                          const SizedBox(height: 40),

                          // ── تاريخ الانتهاء + CVC ──────────────────────────
                          Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _fieldLabel("تاريخ الانتهاء"),
                              const SizedBox(height: 10),
                              _cardField(controller: _expiryDateController, keyboardType: TextInputType.datetime,
                                  prefixIcon: Icons.calendar_month_sharp, placeholder: "MM / YY"),
                            ])),
                            const SizedBox(width: 30),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _fieldLabel("رمز CVC"),
                              const SizedBox(height: 10),
                              _cardField(controller: _cvcController, keyboardType: TextInputType.number,
                                  prefixIcon: Icons.lock, placeholder: "123", maxLength: 3, obscure: false),
                            ])),
                          ]),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ── ملخص السعر ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(children: [
                      _priceRow("سعر التذكرة", "${widget.totalPrice.toStringAsFixed(0)} جنية"),
                      const SizedBox(height: 10),
                      _priceRow("رسوم الخدمة", "20 جنية"),
                      const SizedBox(height: 10),
                      _priceRow("السعر الاجمالي", "${(widget.totalPrice + 20).toStringAsFixed(0)} جنية", bold: true),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  // ── رسالة خطأ ─────────────────────────────────────────────
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(_errorMessage!,
                          style: GoogleFonts.cairo(fontSize: 14, color: Colors.red),
                          textAlign: TextAlign.right),
                    ),

                  const SizedBox(height: 10),

                  // ── زرار تأكيد الدفع ──────────────────────────────────────
                  SizedBox(
                    width: 349, height: 76,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _confirmPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(59)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 26, height: 26,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text("تأكيد الدفع",
                          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, color: Colors.grey[600], size: 18),
                      const SizedBox(width: 3),
                      Text("جميع بياناتك أمنة ومشفرة بالكامل",
                          style: GoogleFonts.cairo(fontSize: 15, color: const Color(0xff4D4D4D), fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Row(children: [
    Text(text, style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700)),
  ]);

  Widget _priceRow(String label, String value, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(value, style: GoogleFonts.cairo(fontSize: 24, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: Colors.black)),
      Text(label, style: GoogleFonts.cairo(fontSize: 24, fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: bold ? Colors.black : Colors.grey)),
    ],
  );

  Widget _cardField({
    required TextEditingController controller,
    required TextInputType keyboardType,
    required IconData prefixIcon,
    required String placeholder,
    int? maxLength,
    bool obscure = false,
    bool hasVisaLogo = false,
  }) =>
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(children: [
            if (hasVisaLogo)
              SizedBox(width: 60, height: 28,
                  child: Image.asset("assets/images/icons/5965208742762581520.jpg", fit: BoxFit.contain)),
            Expanded(
              child: TextFormField(
                controller: controller,
                textAlign: hasVisaLogo ? TextAlign.center : TextAlign.right,
                style: GoogleFonts.cairo(fontSize: hasVisaLogo ? 18 : 16, fontWeight: FontWeight.w700, color: Colors.grey),
                obscureText: obscure,
                keyboardType: keyboardType,
                maxLength: maxLength,
                buildCounter: maxLength != null ? (_, {required currentLength, required isFocused, maxLength}) => null : null,
                decoration: InputDecoration(
                  border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                  prefixIcon: Icon(prefixIcon, color: Colors.grey, size: 20),
                  prefixIconConstraints: const BoxConstraints(minWidth: 40),
                ),
                onTap: () { if (controller.text == placeholder) controller.clear(); },
                onEditingComplete: () { if (controller.text.isEmpty) controller.text = placeholder; },
              ),
            ),
          ]),
        ),
      );
}
