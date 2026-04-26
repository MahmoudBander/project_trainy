import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/core/notification_service.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:project_bander/modules/tickts/confirmation_recovery_screen/recovered_screen.dart';
import '../tickets_storage/tickets_storage.dart';

class ConfirmationRecoveryScreen extends StatefulWidget {
  final int ticketId;
  final double ticketPrice;
  const ConfirmationRecoveryScreen({
    super.key,
    this.ticketId = 0,
    this.ticketPrice = 0,
  });
  @override
  State<ConfirmationRecoveryScreen> createState() =>
      _ConfirmationRecoveryScreenState();
}

class _ConfirmationRecoveryScreenState
    extends State<ConfirmationRecoveryScreen> {
  bool _isChecked = false;
  String _tripDate = '---';
  String _refundAmount = '---';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final date = await SessionManager.getTripDate() ?? '';
    if (mounted)
      setState(() {
        _tripDate = date.isNotEmpty ? date : '---';
        if (widget.ticketPrice > 0) {
        _refundAmount = '${(widget.ticketPrice * 0.85).toStringAsFixed(2)} ج.م';
              '${((widget.ticketPrice + 20) * 0.85).toStringAsFixed(2)} ج.م';
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final displayId = widget.ticketId > 0 ? '#${widget.ticketId}' : '#---';
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
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
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
                          'حالة استرداد الاموال',
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
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
                                  color: const Color(0xffBD910D),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  displayId,
                                  style: GoogleFonts.cairo(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'طلب استرداد',
                                  style: GoogleFonts.cairo(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      displayId,
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'تذكرة رقم :',
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _tripDate,
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'تاريخ الرحلة :',
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _refundAmount != '---'
                                          ? _refundAmount
                                          : '85% من المبلغ',
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'المبلغ المسترد :',
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
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'تنبيه',
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.warning,
                              color: Colors.yellowAccent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'قد يتم خصم رسوم ادارية حسب سياسة الاسترداد',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'أوافق على سياسة الاسترداد',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Transform.scale(
                              scale: 1.5,
                              child: Checkbox(
                                value: _isChecked,
                                activeColor: Colors.black,
                                onChanged: (v) =>
                                    setState(() => _isChecked = v ?? false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 68,
                          child: ElevatedButton(
                            onPressed: _isChecked
                                ? () async {
                                    if (widget.ticketId > 0) {
                                      await TicketsStorage.updateStatus(
                                        widget.ticketId,
                                        'cancelled',
                                      );
                                    }
                                    final refund = (widget.ticketPrice * 0.85).toStringAsFixed(0);

                                    await NotificationService.show(
                                      id: widget.ticketId + 2000,
                                      title: 'تم إلغاء التذكرة',
                                      body:
                                          'سيتم استرداد $refund ج.م خلال 3-5 أيام عمل',
                                    );
                                    if (!context.mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => Recoveredscreen(),
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
                              'تأكيد طلب الاسترداد',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                color: _isChecked ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 68,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 10,
                              shadowColor: Colors.black.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(59),
                              ),
                            ),
                            child: Text(
                              'الغاء',
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


