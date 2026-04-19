import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:project_bander/modules/tickts/payment_screen.dart';
import 'package:project_bander/modules/widget/trip_model.dart';

class ConfirmationScreen extends StatefulWidget {
  final List<String> selectedSeats;
  final int          journeyId;
  final TripDetails  tripDetails;

  const ConfirmationScreen({
    super.key,
    required this.selectedSeats,
    required this.journeyId,
    required this.tripDetails,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool   isSwitched       = false;
  bool   _hasSubscription = false;
  bool   _hasDiscount     = false;
  double _discountPercent = 0;

  double get pricePerSeat {
    try {
      final priceStr = widget.tripDetails.ticketTypes.first.price;
      final match = RegExp(r'\d+').firstMatch(priceStr);
      if (match != null) return double.parse(match.group(0)!);
    } catch (_) {}
    return 150.0;
  }

  @override
  void initState() {
    super.initState();
    _loadUserBenefits();
  }

  Future<void> _loadUserBenefits() async {
    final accountId = await SessionManager.getAccountId() ?? 0;
    final subResult  = await ApiService().getSubscription(accountId);
    final discResult = await ApiService().getMyDiscount(accountId);
    if (mounted) {
      setState(() {
        if (subResult['success'] == true && subResult['data'] != null) {
          final subData = subResult['data'];
          Map<String, dynamic>? activeSub;
          if (subData is Map) {
            activeSub = Map<String, dynamic>.from(subData);
          } else if (subData is List && subData.isNotEmpty) {
            final active = subData.firstWhere(
                  (e) => e is Map && (e['isActive'] == true),
              orElse: () => null,
            );
            if (active != null) activeSub = Map<String, dynamic>.from(active);
          }
          _hasSubscription = activeSub != null && (activeSub['isActive'] ?? false) == true;
          // مش بنفعّل السويتش تلقائياً — المستخدم يختار
        }
        if (discResult['success'] == true && discResult['data'] != null) {
          _hasDiscount     = true;
          final cat = (discResult['data']['userCategory'] ?? '').toString().toLowerCase();
          _discountPercent = (cat == 'military' || cat == 'disabled') ? 100 : 50;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double basePrice  = widget.selectedSeats.length * pricePerSeat;
    if (_hasDiscount) basePrice = basePrice * (1 - _discountPercent / 100);
    double totalPrice = isSwitched && _hasSubscription ? 0 : basePrice;

    return Scaffold(
      body: Stack(
        children: [
          // ── خلفية ────────────────────────────────────────────────────────
          Column(children: [
            Container(height: 200, width: double.infinity, color: Colors.black),
            Expanded(child: Container(width: double.infinity, color: Colors.white)),
          ]),

          // ── هيدر ─────────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white)),
                const SizedBox(width: 60),
                Text("ملخص الحجز",
                    style: GoogleFonts.cairo(fontSize: 24,
                        fontWeight: FontWeight.w700, color: Colors.white)),
                const Spacer(),
              ]),
            ),
          ),

          // ── المحتوى ───────────────────────────────────────────────────────
          Positioned(
            top: 150, left: 32, right: 32, bottom: 20,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── كارت تفاصيل الرحلة ─────────────────────────────────
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
                      child: Column(children: [
                        // اسم القطار + نوعه
                        Row(children: [
                          Text(widget.tripDetails.trainName,
                              style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 22)),
                          const Spacer(),
                          Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.amberAccent),
                              child: Text(widget.tripDetails.tripType,
                                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700))),
                        ]),
                        const SizedBox(height: 16),

                        // من ← إلى
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    const Icon(Icons.location_on, size: 18),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(widget.tripDetails.from,
                                        style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600),
                                        softWrap: true)),
                                  ]),
                                  const SizedBox(height: 4),
                                  Text(
                                      widget.tripDetails.stations.isNotEmpty
                                          ? widget.tripDetails.stations.first.time : '',
                                      style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Row(children: [
                                Icon(Icons.train, size: 18),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward, size: 18),
                              ]),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(children: [
                                    Expanded(child: Text(widget.tripDetails.to,
                                        style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.end, softWrap: true)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.location_on, size: 18),
                                  ]),
                                  const SizedBox(height: 4),
                                  Text(
                                      widget.tripDetails.stations.length > 1
                                          ? widget.tripDetails.stations.last.time : '',
                                      style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                                      textAlign: TextAlign.end),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // المقاعد
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text("المقاعد", style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey)),
                          Text("عربة 3، مقاعد ${widget.selectedSeats.join(', ')}",
                              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 16),

                        // نوع التذكرة
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text("نوع التذكرة", style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey)),
                          Text("ذهاب فقط", style: GoogleFonts.cairo(fontSize: 16)),
                        ]),
                        const SizedBox(height: 16),

                        // سعر التذكرة
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text("سعر التذكرة (X${widget.selectedSeats.length})",
                              style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey)),
                          Text("${totalPrice.toStringAsFixed(2)} ج.م",
                              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 8),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── خصم ذوي الاحتياجات ────────────────────────────────────
                  if (_hasDiscount)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text(
                            _discountPercent == 100 ? "تذكرة مجانية مطبّقة ✓"
                                : "خصم ${_discountPercent.toInt()}% مطبّق ✓",
                            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700,
                                color: Colors.green.shade800)),
                        const SizedBox(width: 8),
                        Icon(Icons.verified, color: Colors.green.shade700, size: 20),
                      ]),
                    ),

                  // ── سويتش الاشتراك ────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Switch(
                        value: isSwitched,
                        onChanged: _hasSubscription
                            ? (value) => setState(() => isSwitched = value)
                            : null,
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey.shade300,
                      ),
                      Row(children: [
                        Text(
                            _hasSubscription ? "تطبيق خصم الاشتراك" : "لا يوجد اشتراك نشط",
                            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700,
                                color: _hasSubscription ? Colors.black : Colors.grey)),
                        const SizedBox(width: 6),
                        Icon(Icons.workspace_premium,
                            color: _hasSubscription ? const Color(0xffF2EE08) : Colors.grey),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── المجموع الإجمالي ──────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (_hasDiscount || (isSwitched && _hasSubscription))
                          Text(
                              "${(widget.selectedSeats.length * pricePerSeat).toStringAsFixed(0)} ج.م",
                              style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey,
                                  decoration: TextDecoration.lineThrough)),
                        Text(
                            totalPrice == 0 ? "مجاني" : "${totalPrice.toStringAsFixed(0)} ج.م",
                            style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700,
                                color: totalPrice == 0 ? Colors.green : Colors.black)),
                      ]),
                      Text("المجموع الاجمالي",
                          style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── زرار الانتقال للدفع ───────────────────────────────────
                  SizedBox(
                    width: double.infinity, height: 72,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => PaymentScreen(
                            totalPrice:    totalPrice,
                            journeyId:     widget.journeyId,
                            selectedSeats: widget.selectedSeats,
                          ))),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(59))),
                      child: Text("الانتقال للدفع",
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w700,
                              fontSize: 32, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── زرار الإلغاء ──────────────────────────────────────────
                  SizedBox(
                    width: double.infinity, height: 72,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 10,
                          shadowColor: Colors.black.withOpacity(0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(59))),
                      child: Text("الغاء",
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w700,
                              fontSize: 32, color: Colors.black)),
                    ),
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
}
