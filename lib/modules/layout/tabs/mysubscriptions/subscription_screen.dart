import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:project_bander/modules/layout/tabs/mysubscriptions/subscription_records.dart';
import 'package:project_bander/modules/layout/tabs/subscriptions_tab.dart';
import '../../home.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  Map<String, dynamic>? _sub;
  bool _isLoading = true;
  bool _isCancelling = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final accountId = await SessionManager.getAccountId() ?? 0;
    final result = await ApiService().getSubscription(accountId);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          final data = result['data'];
          // الـ server ممكن يرجع Map أو List
          if (data is Map) {
            _sub = Map<String, dynamic>.from(data);
          } else if (data is List && data.isNotEmpty) {
            // لو List خد أول اشتراك نشط
            final active = data.firstWhere(
              (e) => e is Map && (e['isActive'] == true),
              orElse: () => data.first,
            );
            _sub = active is Map ? Map<String, dynamic>.from(active) : null;
          } else {
            _sub = null;
          }
        } else {
          _error = result['message'];
        }
      });
    }
  }

  Future<void> _cancelSubscription() async {
    if (_sub == null) return;
    final subId = _sub!['subscriptionId'] ?? _sub!['id'];
    if (subId == null) return;

    setState(() => _isCancelling = true);
    final result = await ApiService().cancelSubscription(subId);
    if (!mounted) return;
    setState(() => _isCancelling = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("تم إلغاء الاشتراك", style: GoogleFonts.cairo()),
          backgroundColor: Colors.green,
        ),
      );
      _loadSubscription();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'فشل الإلغاء',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _planName(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'yearly':
      case 'year':
        return 'اشتراك سنوي';
      case 'monthly':
      case 'month':
        return 'اشتراك شهري';
      case 'weekly':
      case 'week':
        return 'اشتراك أسبوعي';
      default:
        return type ?? 'اشتراك';
    }
  }

  String _formatDate(String? d) {
    if (d == null || d.isEmpty) return '---';
    try {
      final dt = DateTime.parse(d);
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (_) {
      return d;
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
                height: 160,
                width: double.infinity,
                color: Colors.white,
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      bottom: 30,
                      child: IconButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          Home.route,
                          (r) => false,
                          arguments: 2,
                        ),
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
                          'اشتراكي',
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
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadSubscription,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          child: _sub == null
                              ? _buildNoSubscription()
                              : _buildSubscriptionCard(),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubscription() {
    return Column(
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.card_membership_outlined,
          size: 80,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 20),
        Text(
          "لا يوجد اشتراك نشط",
          style: GoogleFonts.cairo(fontSize: 20, color: Colors.grey),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionsTab()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(59),
              ),
            ),
            child: Text(
              "تصفح الباقات",
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard() {
    final planType =
        _sub!['typeSubscription'] ?? _sub!['planType'] ?? _sub!['type'] ?? '';
    final startDate = _formatDate(_sub!['startDate']);
    final endDate = _formatDate(_sub!['endDate']);
    final discount = _sub!['discountPercentage'] ?? _sub!['discount'] ?? 0;
    final usedTrips = _sub!['usedTrips'] ?? _sub!['tripsUsed'] ?? 0;
    final totalTrips = _sub!['totalTrips'] ?? _sub!['tripsTotal'] ?? 12;
    final isActive = (_sub!['isActive'] ?? true) == true;
    final progress = totalTrips > 0
        ? (usedTrips / totalTrips).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        // ── كارت الاشتراك ──────────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.lightGreenAccent
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        isActive ? 'نشط' : 'منتهي',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                    Text(
                      _planName(planType),
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "صالح : $startDate  _  $endDate",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "%الخصم : $discount",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$totalTrips / $usedTrips",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "الرحلات المستخدمة",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(54),
                    child: LinearProgressIndicator(
                      value: progress.toDouble(),
                      minHeight: 15,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.yellow,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),

        // ── زر تجديد ──────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 69,
          child: ElevatedButton(
            onPressed: () => _showRenewDialog(planType),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              elevation: 10,
              shadowColor: Colors.black.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(59),
              ),
            ),
            child: Text(
              "تجديد الاشتراك",
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ── سجل الاشتراكات ────────────────────────────────────────────────
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SubscriptionRecords()),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "عرض سجل الاشتراكات",
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showRenewDialog(String planType) {
    final prices = {'Yearly': 1200, 'Monthly': 300, 'Weekly': 90};
    final price = prices[planType] ?? 0;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, _, __) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 355,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 25),
                Text(
                  "سيتم تجديد اشتراكك الحالي بنفس الباقة",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "الاشتراك  : ${_planName(planType)}",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "السعر  : $price جنية",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2F2F2),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "إلغاء",
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final accountId =
                              await SessionManager.getAccountId() ?? 0;
                          final result = await ApiService().createSubscription(
                            accountId: accountId,
                            planType: planType,
                          );
                          if (!context.mounted) return;
                          if (result['success'] == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "تم التجديد بنجاح!",
                                  style: GoogleFonts.cairo(),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _loadSubscription();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ?? 'فشل التجديد',
                                  style: GoogleFonts.cairo(),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "تأكيد",
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
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
}
