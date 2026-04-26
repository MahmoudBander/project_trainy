import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/core/notification_service.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:project_bander/modules/tickts/booked_screen.dart';
import 'package:project_bander/modules/tickts/tickets_storage/tickets_storage.dart';

class ConfirmPayment extends StatefulWidget {
  final String? paymentMethod;
  final int journeyId;
  final List<String> selectedSeats;
  final double totalPrice;

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
  final _cardNumberController = TextEditingController(
    text: "13458757654309765",
  );
  final _cardHolderController = TextEditingController(
    text: "ادخل الاسم كما هو علي البطاقة",
  );
  final _expiryDateController = TextEditingController(text: "MM / YY");
  final _cvcController = TextEditingController(text: "123");

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _saveTicketLocally(int ticketId) async {
    final from  = await SessionManager.getFromStation() ?? '';
    final to    = await SessionManager.getToStation()   ?? '';
    final train = await SessionManager.getTrainName()   ?? '';
    final date  = await SessionManager.getTripDate()    ?? '';
    final dep   = await SessionManager.getDeparture()   ?? '';
    final arr   = await SessionManager.getArrival()     ?? '';
    final seat  = await SessionManager.getSeatNumber()  ?? '';
    final price = await SessionManager.getTicketPrice() ?? widget.totalPrice;

    await TicketsStorage.add(TicketModel(
      ticketId:    ticketId,
      fromStation: from,
      toStation:   to,
      trainName:   train,
      tripDate:    date,
      departure:   dep,
      arrival:     arr,
      seatNumber:  seat,
      ticketPrice: price,
      status:      'upcoming',
      createdAt:   DateTime.now(),
    ));
  }

  Future<void> _sendNotifications(int ticketId) async {
    final totalPaid = (widget.totalPrice + 20).toStringAsFixed(0);
    await NotificationService.show(
      id:    ticketId,
      title: 'تم تاكيد الحجز',
      body:  'تم دفع $totalPaid ج.م بنجاح',
    );
    final dep  = await SessionManager.getDeparture() ?? '';
    // إشعار فوري بوقت القطار
    final depImmediate = dep.replaceAll('وقت المغادرة', '').trim();
    if (depImmediate.isNotEmpty) {
      await NotificationService.show(
        id:    ticketId + 500,
        title: 'تذكير بموعد قطارك',
        body:  'قطارك تحرك الساعة $depImmediate',
      );
    }
    final date = await SessionManager.getTripDate()  ?? '';
    try {
      final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(dep);
      if (timeMatch != null && date.isNotEmpty) {
        int hour   = int.parse(timeMatch.group(1)!);
        int minute = int.parse(timeMatch.group(2)!);
        if (dep.contains('مساء') && hour != 12) hour += 12;
        if (dep.contains('صباح') && hour == 12) hour = 0;
        final tripTime = DateTime.parse(date).add(Duration(hours: hour, minutes: minute));
        final remind   = tripTime.subtract(const Duration(hours: 1));
        final depClean = dep.replaceAll('وقت المغادرة', '').trim();
        await NotificationService.schedule(
          id:            ticketId + 1000,
          title:         'قطارك بعد ساعة',
          body:          'تحرك القطار الساعة $depClean',
          scheduledTime: remind,
        );
      }
    } catch (_) {}
  }

  Future<void> _confirmPayment() async {
    final cardNumber = _cardNumberController.text.trim();
    final cardHolder = _cardHolderController.text.trim();
    final expiry = _expiryDateController.text.trim();
    final cvc = _cvcController.text.trim();

    if (cardNumber.isEmpty || cardNumber.length < 13) {
      setState(() => _errorMessage = 'من فضلك ادخل رقم البطاقة صح');
      return;
    }
    if (cardHolder.isEmpty || cardHolder == "ادخل الاسم كما هو علي البطاقة") {
      setState(() => _errorMessage = 'من فضلك ادخل اسم صاحب البطاقة');
      return;
    }
    if (expiry.isEmpty || expiry == "MM / YY") {
      setState(() => _errorMessage = 'من فضلك ادخل تاريخ الانتهاء');
      return;
    }
    if (cvc.isEmpty || cvc.length < 3) {
      setState(() => _errorMessage = 'من فضلك ادخل رمز CVC صح');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accountId = await SessionManager.getAccountId() ?? 0;
      final api = ApiService();
      final List<int> createdTicketIds = [];

      if (widget.journeyId == 0) {
        await Future.delayed(const Duration(seconds: 1));
        final savedId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await _saveTicketLocally(savedId);
        await _sendNotifications(savedId);
        if (!mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => BookedScreen(ticketIds: [1, 2, 3])));
        return;
      }

      for (final seatStr in widget.selectedSeats) {
        final seatNumber =
            int.tryParse(seatStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
        final bookResult = await api.createTicket(
          journeyId: widget.journeyId,
          seatNumber: seatNumber,
          accountId: accountId,
        );
        if (bookResult['success'] != true) {
          setState(() {
            _isLoading = false;
            _errorMessage = bookResult['message'] ?? 'فشل حجز المقعد $seatStr';
          });
          return;
        }
        final ticketId =
            bookResult['data']?['ticketId'] ?? bookResult['data']?['id'];
        if (ticketId != null) createdTicketIds.add(ticketId);
      }

      for (final ticketId in createdTicketIds) {
        final payResult = await api.payTicket(ticketId);
        if (payResult['success'] != true) {
          setState(() {
            _isLoading = false;
            _errorMessage = payResult['message'] ?? 'فشل الدفع';
          });
          return;
        }
      }

      final savedId = createdTicketIds.isNotEmpty ? createdTicketIds.first : 0;
      await _saveTicketLocally(savedId);
      await _sendNotifications(savedId);

      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => BookedScreen(ticketIds: createdTicketIds)));

    } catch (_) {
      if (mounted)
        setState(() {
          _isLoading = false;
          _errorMessage = 'حدث خطأ، تحقق من الاتصال';
        });
    }
  }

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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 85),
                  Text(
                    "بيانات الدفع",
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
            left: 10,
            right: 10,
            bottom: 40,
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
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.payment_rounded,
                                color: Colors.black,
                                size: 35,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "بيانات بطاقة الائتمان",
                                style: GoogleFonts.cairo(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
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
                          _fieldLabel("اسم صاحب البطاقة"),
                          const SizedBox(height: 15),
                          _cardField(
                            controller: _cardHolderController,
                            keyboardType: TextInputType.text,
                            prefixIcon: Icons.person,
                            placeholder: "ادخل الاسم كما هو علي البطاقة",
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _fieldLabel("تاريخ الانتهاء"),
                                    const SizedBox(height: 10),
                                    _cardField(
                                      controller: _expiryDateController,
                                      keyboardType: TextInputType.datetime,
                                      prefixIcon: Icons.calendar_month_sharp,
                                      placeholder: "MM / YY",
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 30),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _fieldLabel("رمز CVC"),
                                    const SizedBox(height: 10),
                                    _cardField(
                                      controller: _cvcController,
                                      keyboardType: TextInputType.number,
                                      prefixIcon: Icons.lock,
                                      placeholder: "123",
                                      maxLength: 3,
                                      obscure: false,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _priceRow(
                          "سعر التذكرة",
                          "${widget.totalPrice.toStringAsFixed(0)} جنية",
                        ),
                        const SizedBox(height: 10),
                        _priceRow("رسوم الخدمة", "20 جنية"),
                        const SizedBox(height: 10),
                        _priceRow(
                          "السعر الاجمالي",
                          "${(widget.totalPrice + 20).toStringAsFixed(0)} جنية",
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 349,
                    height: 76,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _confirmPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(59),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Text(
                        "تأكيد الدفع",
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, color: Colors.grey[600], size: 18),
                      const SizedBox(width: 3),
                      Text(
                        "جميع بياناتك أمنة ومشفرة بالكامل",
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          color: const Color(0xff4D4D4D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _fieldLabel(String text) => Row(
    children: [
      Text(
        text,
        style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    ],
  );

  Widget _priceRow(String label, String value, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        value,
        style: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: Colors.black,
        ),
      ),
      Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: bold ? Colors.black : Colors.grey,
        ),
      ),
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
  }) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          if (hasVisaLogo)
            SizedBox(
              width: 60,
              height: 28,
              child: Image.asset(
                "assets/images/icons/5965208742762581520.jpg",
                fit: BoxFit.contain,
              ),
            ),
          Expanded(
            child: TextFormField(
              controller: controller,
              textAlign: hasVisaLogo ? TextAlign.center : TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: hasVisaLogo ? 18 : 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
              obscureText: obscure,
              keyboardType: keyboardType,
              maxLength: maxLength,
              buildCounter: maxLength != null
                  ? (_, {required currentLength, required isFocused, maxLength}) => null
                  : null,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                prefixIcon: Icon(prefixIcon, color: Colors.grey, size: 20),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
              ),
              onTap: () {
                if (controller.text == placeholder) controller.clear();
              },
              onEditingComplete: () {
                if (controller.text.isEmpty) controller.text = placeholder;
              },
            ),
          ),
        ],
      ),
    ),
  );
}
