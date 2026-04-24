import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:project_bander/modules/tickts/confirmation_recovery_screen/recovery_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../layout/home.dart';

class QRScreen extends StatefulWidget {
  final int ticketId;
  const QRScreen({super.key, required this.ticketId});
  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  Map<String, dynamic>? _ticketData;
  bool _isLoading = true;
  String? _userName;
  String _savedFrom = '';
  String _savedTo = '';
  String _savedDep = '';
  String _savedArr = '';
  String _savedTrain = '';
  String _savedDate = '';
  String _savedSeat = '';

  @override
  void initState() {
    super.initState();
    _loadTicketData();
  }

  Future<void> _loadTicketData() async {
    final accountId = await SessionManager.getAccountId() ?? 0;
    final name = await SessionManager.getName() ?? '';
    final result = await ApiService().myTickets(accountId);
    final savedFrom = await SessionManager.getFromStation() ?? '';
    final savedTo = await SessionManager.getToStation() ?? '';
    final savedDeparture = await SessionManager.getDeparture() ?? '';
    final savedArrival = await SessionManager.getArrival() ?? '';
    final savedTrain = await SessionManager.getTrainName() ?? '';
    final savedDate = await SessionManager.getTripDate() ?? '';
    final savedSeat = await SessionManager.getSeatNumber() ?? '';

    if (mounted) {
      setState(() {
        _isLoading = false;
        _userName = name.isNotEmpty ? name : 'مستخدم';
        _savedFrom = savedFrom;
        _savedTo = savedTo;
        _savedDep = savedDeparture;
        _savedArr = savedArrival;
        _savedTrain = savedTrain;
        _savedDate = savedDate;
        _savedSeat = savedSeat;

        if (result['success'] == true && result['data'] != null) {
          final data = result['data'];
          final List tickets = data is List ? data : [data];
          try {
            _ticketData = tickets.firstWhere(
              (t) =>
                  t['ticketId'] == widget.ticketId ||
                  t['id'] == widget.ticketId,
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
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m ${dt.hour >= 12 ? "مساءاً" : "صباحاً"}';
    } catch (_) {
      return raw;
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '---';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw.split('T').first;
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  "تأكيد الالغاء",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "هل انت متأكد من رغبتك في الغاء هذه التذكرة؟",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "سيتم استرداد 85% من المبلغ وفقاً لسياسة الالغاء",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: const Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          // ── التعديل: تمرير ticketId ──────────────────
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RecoveryScreen(ticketId: widget.ticketId),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            "تأكيد",
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F4F6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            "الغاء",
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4B5563),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fromStation = _savedFrom.isNotEmpty
        ? _savedFrom
        : (_ticketData?['fromStation'] ?? '---');
    final toStation = _savedTo.isNotEmpty
        ? _savedTo
        : (_ticketData?['toStation'] ?? '---');
    final trainName = _savedTrain.isNotEmpty
        ? _savedTrain
        : (_ticketData?['trainName'] ?? 'قطار');
    final departure = _savedDep.isNotEmpty
        ? _savedDep
        : _formatTime(_ticketData?['departureTime']);
    final arrival = _savedArr.isNotEmpty
        ? _savedArr
        : _formatTime(_ticketData?['arrivalTime']);
    final date = _savedDate.isNotEmpty
        ? _savedDate
        : _formatDate(_ticketData?['bookingDate']);
    final seatNumber = _savedSeat.isNotEmpty
        ? _savedSeat
        : (_ticketData?['seatNumber']?.toString() ?? '---');
    final wagonNumber = _ticketData?['wagonNumber']?.toString() ?? '---';
    final qrCode = _ticketData?['qrCode'] ?? 'TICKET-${widget.ticketId}';
    final qrContent =
        'اسم المسافر: $_userName\nالقطار: $trainName\nمن: $fromStation\nإلى: $toStation\nالمقعد: $seatNumber\nالعربة: $wagonNumber\nمغادرة: $departure\nوصول: $arrival\nتاريخ: $date\nرمز: $qrCode';

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
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "تأكيد الحجز",
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
          Positioned(
            top: 130,
            left: 20,
            right: 20,
            bottom: 30,
            child: Column(
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "الوجهة",
                                            style: GoogleFonts.cairo(
                                              color: Colors.grey[500],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            "$fromStation ⟵ $toStation",
                                            style: GoogleFonts.cairo(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          trainName,
                                          textAlign: TextAlign.end,
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),

                                  QrImageView(
                                    data: qrContent,
                                    version: QrVersions.auto,
                                    size: 180.0,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "امسح الرمز عند بوابة الدخول",
                                    style: GoogleFonts.cairo(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  _buildInfoRow(
                                    "الاسم",
                                    _userName ?? '---',
                                    "تاريخ الرحلة",
                                    date,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInfoRow(
                                    "وقت المغادرة",
                                    departure,
                                    "وقت الوصول",
                                    arrival,
                                  ),
                                  const SizedBox(height: 20),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailItem(
                                        "العربة / المقعد",
                                        "$wagonNumber / $seatNumber",
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "الحالة",
                                            style: GoogleFonts.cairo(
                                              color: Colors.grey[500],
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFD1FAE5),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Text(
                                              "مدفوعة",
                                              style: GoogleFonts.cairo(
                                                color: const Color(0xFF065F46),
                                                fontWeight: FontWeight.w900,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 72,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      Home.route,
                      (route) => false,
                      arguments: 4,
                    ),
                    icon: const Icon(
                      Icons.file_download_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                    label: Text(
                      "تحميل التذكرة PDF",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(59),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                GestureDetector(
                  onTap: _showCancelDialog,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "الغاء التذكرة",
                        style: GoogleFonts.cairo(
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.cancel,
                        color: Color(0xFFEF4444),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String l1, String v1, String l2, String v2) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: _buildDetailItem(l1, v1)),
      const SizedBox(width: 12),
      Expanded(child: _buildDetailItem(l2, v2)),
    ],
  );

  Widget _buildDetailItem(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.cairo(
          color: Colors.grey[500],
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      Text(
        value,
        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w900),
      ),
    ],
  );
}
