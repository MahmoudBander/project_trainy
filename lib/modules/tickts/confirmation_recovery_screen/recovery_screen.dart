import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:project_bander/modules/tickts/tickets_storage/tickets_storage.dart';
import 'confirmation_recovery_screen.dart';

class RecoveryScreen extends StatefulWidget {
  final int    ticketId;
  final double ticketPrice;
  const RecoveryScreen({super.key, this.ticketId = 0, this.ticketPrice = 0});
  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  String? selectedReason;
  bool   _isLoading = false;
  String _tripDate    = '---';
  String _refundId    = '---';
  double _ticketPrice = 0;

  @override
  void initState() {
    super.initState();
    _loadDate();
  }

  Future<void> _loadDate() async {
    final date    = await SessionManager.getTripDate() ?? '';
    // جيب السعر من الـ TicketsStorage بالـ ticketId مش من SessionManager
    final tickets = await TicketsStorage.getAll();
    final ticket  = tickets.where((t) => t.ticketId == widget.ticketId).toList();
    final price   = ticket.isNotEmpty ? ticket.first.ticketPrice : widget.ticketPrice;
    if (mounted) setState(() {
      _tripDate    = date.isNotEmpty ? date : '---';
      _ticketPrice = price;
    });
  }

  Future<void> _cancelTicket(String reason) async {
    if (widget.ticketId == 0) {
      if (mounted) Navigator.push(context,
          MaterialPageRoute(builder: (_) => ConfirmationRecoveryScreen()));
      return;
    }
    setState(() => _isLoading = true);
    final result = await ApiService().cancelTicket(
        ticketId: widget.ticketId, reason: reason);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final data = result['data'];
      String refundId = widget.ticketId.toString();
      if (data is Map) {
        refundId = (data['refundId'] ?? data['id'] ?? data['requestId'] ?? widget.ticketId).toString();
      }
      setState(() => _refundId = refundId);
    }
    if (mounted) Navigator.push(context,
        MaterialPageRoute(builder: (_) => ConfirmationRecoveryScreen(
          ticketId:    widget.ticketId,
          ticketPrice: _ticketPrice > 0 ? _ticketPrice : widget.ticketPrice,
        )));
  }

  @override
  Widget build(BuildContext context) {
    final displayId = _refundId != '---' ? _refundId : widget.ticketId.toString();

    return Scaffold(
      body: Stack(children: [
        Column(children: [
          Container(
            height: 160, width: double.infinity, color: Colors.white,
            child: Stack(children: [
              Positioned(
                  left: 16, bottom: 30,
                  child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      iconSize: 24, color: Colors.black)),
              Positioned(
                  left: 0, right: 0, bottom: 40,
                  child: Center(
                      child: Text('حالة استرداد الاموال',
                          style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700)))),
            ]),
          ),
          Container(height: 1, width: double.infinity, color: Colors.grey[300]),
          Expanded(
            child: Container(
              width: double.infinity, color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.yellowAccent,
                                borderRadius: BorderRadius.circular(100)),
                            child: Text('معلق',
                                style: GoogleFonts.cairo(fontSize: 13,
                                    fontWeight: FontWeight.w700, color: const Color(0xffBD910D)))),
                        Row(children: [
                          Text('#$displayId',
                              style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 10),
                          Text("طلب استرداد",
                              style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w400)),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 1),
                        boxShadow: [BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 4, offset: const Offset(0, 4))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('#$displayId',
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700,
                                      fontSize: 20, color: Colors.grey)),
                              Text("تذكرة رقم :",
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.w400,
                                      fontSize: 20, color: Colors.black)),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_tripDate,
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700,
                                      fontSize: 20, color: Colors.grey)),
                              Text("تاريخ الرحلة :",
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.w400,
                                      fontSize: 20, color: Colors.black)),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("85% من المبلغ المدفوع",
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700,
                                      fontSize: 20, color: Colors.black)),
                              Text("المبلغ المسترد :",
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.w400,
                                      fontSize: 20, color: Colors.black)),
                            ],
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text("سبب الاسترداد ؟",
                          style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 24),
                    ...['الغاء الرحلة', 'تغيير موعد السفر', 'خطأ في الحجز', 'سبب آخر']
                        .map((reason) => _buildReasonTile(reason)),
                    if (_isLoading)
                      const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(child: CircularProgressIndicator(color: Colors.black))),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildReasonTile(String reason) {
    return GestureDetector(
      onTap: _isLoading ? null : () {
        setState(() => selectedReason = reason);
        _cancelTicket(reason);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(reason,
                style: GoogleFonts.cairo(fontSize: 24,
                    fontWeight: FontWeight.w400, color: Colors.black)),
            const SizedBox(width: 20),
            Icon(
                selectedReason == reason
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Colors.black, size: 35),
          ],
        ),
      ),
    );
  }
}
