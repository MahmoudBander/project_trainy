import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/core/session_manager.dart';

class SubscriptionRecords extends StatefulWidget {
  final VoidCallback? onBack;
  const SubscriptionRecords({super.key, this.onBack});
  @override
  State<SubscriptionRecords> createState() => _SubscriptionRecordsState();
}

class _SubscriptionRecordsState extends State<SubscriptionRecords> {
  Map<String, dynamic>? _sub;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final accountId = await SessionManager.getAccountId() ?? 0;
    final result    = await ApiService().getSubscription(accountId);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          final data = result['data'];
          if (data is Map) {
            _sub = Map<String, dynamic>.from(data);
          } else if (data is List && data.isNotEmpty) {
            final active = data.firstWhere(
                  (e) => e is Map && (e['isActive'] == true),
              orElse: () => data.first,
            );
            _sub = active is Map ? Map<String, dynamic>.from(active) : null;
          }
        }
      });
    }
  }

  String _planName(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'yearly':
      case 'year':   return 'الاشتراك السنوي';
      case 'monthly':
      case 'month':  return 'الاشتراك الشهري';
      case 'weekly':
      case 'week':   return 'الاشتراك الأسبوعي';
      default:       return type ?? 'اشتراك';
    }
  }

  String _formatDate(String? d) {
    if (d == null || d.isEmpty) return '---';
    try {
      final dt = DateTime.parse(d);
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (_) { return d; }
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
                          onPressed: () { if (widget.onBack != null) { widget.onBack!(); } else { Navigator.pop(context); } },
                          icon: const Icon(Icons.arrow_back), iconSize: 24, color: Colors.black)),
                  Positioned(left: 0, right: 0, bottom: 40,
                      child: Center(child: Text('سجل الاشتراكات',
                          style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700)))),
                ]),
              ),
              Container(height: 1, width: double.infinity, color: Colors.grey[300]),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.black))
                    : _sub == null
                    ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text("لا يوجد سجل اشتراكات",
                          style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey)),
                    ]))
                    : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildRecord(_sub!)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecord(Map<String, dynamic> sub) {
    final isActive  = (sub['isActive'] ?? true) == true;
    final planType  = sub['typeSubscription'] ?? sub['planType'] ?? sub['type'] ?? '';
    final startDate = _formatDate(sub['startDate']);
    final endDate   = _formatDate(sub['endDate']);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(26),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 5))]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                decoration: BoxDecoration(
                    color: isActive ? const Color(0xff67E771) : Colors.grey,
                    borderRadius: BorderRadius.circular(5)),
                child: Text(isActive ? 'ساري' : 'منتهي',
                    style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white))),
            Text(_planName(planType),
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
          ]),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text("تاريخ البداية : $startDate",
                style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.grey)),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text("تاريخ النهاية : $endDate",
                style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.grey)),
          ]),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}
