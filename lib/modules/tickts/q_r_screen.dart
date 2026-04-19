import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:project_bander/modules/tickts/confirmation_recovery_screen/recovery_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScreen extends StatefulWidget {
  final int ticketId;
  const QRScreen({super.key, required this.ticketId});
  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  Map<String, dynamic>? _ticketData;
  bool    _isLoading = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadTicketData();
  }

  Future<void> _loadTicketData() async {
    final accountId = await SessionManager.getAccountId() ?? 0;
    final name      = await SessionManager.getName() ?? '';
    final result    = await ApiService().myTickets(accountId);
    if (mounted) {
      setState(() {
        _isLoading = false;
        _userName  = name.isNotEmpty ? name : 'مستخدم';
        if (result['success'] == true && result['data'] != null) {
          final data = result['data'];
          final List tickets = data is List ? data : [data];
          try {
            _ticketData = tickets.firstWhere(
                  (t) => t['ticketId'] == widget.ticketId || t['id'] == widget.ticketId,
              orElse: () => tickets.isNotEmpty ? tickets.last : null,
            );
          } catch (_) {
            _ticketData = tickets.isNotEmpty ? tickets.last : null;
          }
        }
      });
    }
  }

  String _formatTime(String? raw) {
    if (raw == null || raw.isEmpty) return '---';
    try {
      final dt = DateTime.parse(raw);
      final h  = dt.hour.toString().padLeft(2, '0');
      final m  = dt.minute.toString().padLeft(2, '0');
      return '$h:$m ${dt.hour >= 12 ? "مساءاً" : "صباحاً"}';
    } catch (_) { return raw; }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '---';
    try {
      final dt = DateTime.parse(raw);
      const months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو',
        'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) { return raw.split('T').first; }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Color(0xFFEF4444), size: 40)),
              const SizedBox(height: 20),
              Text("تأكيد الالغاء",
                  style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("هل انت متأكد من رغبتك في الغاء هذه التذكرة؟",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 15, color: const Color(0xFF6B7280))),
              const SizedBox(height: 20),
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(15)),
                  child: Text("سيتم استرداد 85% من المبلغ وفقاً لسياسة الالغاء",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF374151), fontWeight: FontWeight.w600))),
              const SizedBox(height: 30),
              Row(children: [
                Expanded(child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => RecoveryScreen())),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: Text("تأكيد",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5E7EB), elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: Text("الغاء",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF4B5563), fontSize: 18)))),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fromStation = _ticketData?['fromStation'] ?? '---';
    final toStation   = _ticketData?['toStation']   ?? '---';
    final trainName   = _ticketData?['trainName']   ?? 'قطار';
    final departure   = _formatTime(_ticketData?['departureTime']);
    final arrival     = _formatTime(_ticketData?['arrivalTime']);
    final date        = _formatDate(_ticketData?['bookingDate'] ?? _ticketData?['departureTime']);
    final seatNumber  = _ticketData?['seatNumber']?.toString()  ?? '---';
    final wagonNumber = _ticketData?['wagonNumber']?.toString() ?? '---';
    final qrCode      = _ticketData?['qrCode'] ?? 'TICKET-${widget.ticketId}';

    // بيانات الـ QR كاملة
    final qrContent = '''
اسم المسافر: $_userName
القطار: $trainName
من: $fromStation
إلى: $toStation
المقعد: $seatNumber
العربة: $wagonNumber
وقت المغادرة: $departure
وقت الوصول: $arrival
التاريخ: $date
رمز التذكرة: $qrCode
''';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(children: [
        // ── هيدر ────────────────────────────────────────────────────────────
        SafeArea(
          bottom: false,
          child: SizedBox(
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white))),
                Text("تأكيد الحجز",
                    style: GoogleFonts.cairo(fontSize: 24,
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),

        // ── الكارت الأبيض ────────────────────────────────────────────────────
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30)),
            ),
            child: Column(children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.black))
                    : Directionality(
                  textDirection: TextDirection.rtl,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // ── الوجهة + اسم القطار ─────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trainName,
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w900, fontSize: 16)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("الوجهة",
                                    style: GoogleFonts.cairo(
                                        color: Colors.grey[500],
                                        fontSize: 14, fontWeight: FontWeight.w600)),
                                Text("$fromStation ⟵ $toStation",
                                    style: GoogleFonts.cairo(
                                        fontSize: 18, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── QR Code ─────────────────────────────────
                        Center(
                          child: QrImageView(
                              data: qrContent,
                              version: QrVersions.auto,
                              size: 180.0),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text("امسح الرمز عند بوابة الدخول",
                              style: GoogleFonts.cairo(
                                  color: Colors.grey[400],
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 24),

                        // ── الاسم + تاريخ الرحلة ────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _detailItem("تاريخ الرحلة", date),
                            _detailItem("الاسم", _userName ?? '---'),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── وقت المغادرة + وقت الوصول ───────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _detailItem("وقت الوصول", arrival),
                            _detailItem("وقت المغادرة", departure),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── المقعد + الحالة ──────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("الحالة",
                                    style: GoogleFonts.cairo(
                                        color: Colors.grey[500],
                                        fontSize: 13, fontWeight: FontWeight.w600)),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFD1FAE5),
                                        borderRadius: BorderRadius.circular(15)),
                                    child: Text("مدفوعة",
                                        style: GoogleFonts.cairo(
                                            color: const Color(0xFF065F46),
                                            fontWeight: FontWeight.w900, fontSize: 12))),
                              ],
                            ),
                            _detailItem("العربة / المقعد", "$wagonNumber/$seatNumber"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── زرار تحميل PDF ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SizedBox(
                  width: double.infinity, height: 65,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 26),
                    label: Text("تحميل التذكرة PDF",
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(59))),
                  ),
                ),
              ),

              // ── إلغاء التذكرة ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: _showCancelDialog,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("الغاء التذكرة",
                          style: GoogleFonts.cairo(
                              color: const Color(0xFFEF4444),
                              fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(width: 5),
                      const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 18),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _detailItem(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: GoogleFonts.cairo(
              color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600)),
      Text(value,
          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w900)),
    ],
  );
}
