import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/api/api_handler.dart';
import 'confirmation_recovery_screen.dart';

class RecoveryScreen extends StatefulWidget {
  final int ticketId;
  const RecoveryScreen({super.key, this.ticketId = 0});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  String? selectedReason;
  bool    _isLoading = false;

  Future<void> _cancelTicket(String reason) async {
    if (widget.ticketId == 0) {
      // لو مفيش ticketId ننقل للشاشة التالية بس
      if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => ConfirmationRecoveryScreen()));
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiService().cancelTicket(ticketId: widget.ticketId, reason: reason);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ConfirmationRecoveryScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'فشل الإلغاء', style: GoogleFonts.cairo()),
        backgroundColor: Colors.red));
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
                height: 160, width: double.infinity, color: Colors.white,
                child: Stack(children: [
                  Positioned(left: 16, bottom: 30,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back), iconSize: 24, color: Colors.black)),
                  Positioned(left: 0, right: 0, bottom: 40,
                    child: Center(child: Text('حالة استرداد الاموال',
                      style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700)))),
                ]),
              ),
              Container(height: 1, width: double.infinity, color: Colors.grey[300]),
              Expanded(
                child: Container(
                  width: double.infinity, color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.yellowAccent, borderRadius: BorderRadius.circular(100)),
                          child: Text('معلق', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xffBD910D)))),
                        const SizedBox(width: 80),
                        Text(widget.ticketId > 0 ? '#${widget.ticketId}' : '#---',
                          style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 10),
                        Text("طلب استرداد", style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w400)),
                      ]),
                      const SizedBox(height: 40),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text("سبب الاسترداد ؟",
                          style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 24),
                      ...['الغاء الرحلة', 'تغيير موعد السفر', 'خطأ في الحجز', 'سبب آخر'].map((reason) =>
                        _buildReasonTile(reason)),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(child: CircularProgressIndicator(color: Colors.black))),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text(reason, style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w400, color: Colors.black)),
          const SizedBox(width: 20),
          Icon(
            selectedReason == reason ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: Colors.black, size: 35),
        ]),
      ),
    );
  }
}
