import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:project_bander/modules/layout/tabs/mysubscriptions/subscription_records.dart';
import '../home.dart';

class SubscriptionsTab extends StatefulWidget {
  static const route = "SubscriptionsTab";
  const SubscriptionsTab({super.key});
  @override
  State<SubscriptionsTab> createState() => _SubscriptionsTabState();
}

class _SubscriptionsTabState extends State<SubscriptionsTab> {
  // 0 = الاشتراكات المتاحة, 1 = اشتراكاتي, 2 = سجل الاشتراكات
  int _view = 0;

  // بيانات اشتراكاتي
  Map<String, dynamic>? _sub;
  bool _isLoading = false;
  bool _isCancelling = false;

  void _switchView(int view) {
    setState(() => _view = view);
    if (view == 1) _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    setState(() => _isLoading = true);
    final accountId = await SessionManager.getAccountId() ?? 0;
    final result = await ApiService().getSubscription(accountId);
    if (!mounted) return;
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
        } else {
          _sub = null;
        }
      }
    });
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
    // ── سجل الاشتراكات ─────────────────────────────────────────────────────
    if (_view == 2) {
      return SubscriptionRecords(onBack: () => _switchView(1));
    }

    return Scaffold(
      body: Column(
        children: [
          // ── هيدر ─────────────────────────────────────────────────────────
          Container(
            height: 160,
            width: double.infinity,
            color: Colors.white,
            child: Stack(
              children: [
                if (_view == 1)
                  Positioned(
                    left: 16,
                    bottom: 30,
                    child: IconButton(
                      onPressed: () => _switchView(0),
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
                      _view == 0 ? 'الاشتراكات' : 'اشتراكي',
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
          Container(height: 1, width: double.infinity, color: Colors.grey[300]),

          // ── المحتوى ───────────────────────────────────────────────────────
          Expanded(
            child: _view == 0 ? _buildAvailablePlans() : _buildMySubscription(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // الاشتراكات المتاحة
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildAvailablePlans() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── زراري التنقل ──────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _switchView(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F2F2),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                  child: Text(
                    "اشتراكاتي",
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                  child: Text(
                    "الاشتراكات المتاحة",
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPlanCard(
            title: "الاشتراك السنوي",
            duration: "لمدة 12 شهرا",
            price: "1200ج.م",
            trips: "عدد الرحلات : 60 رحلة",
            total: 1200,
            planType: "Yearly",
          ),
          const SizedBox(height: 20),
          _buildPlanCard(
            title: "الاشتراك الشهري",
            duration: "لمدة شهر",
            price: "300ج.م",
            trips: "عدد الرحلات : 12 رحلة",
            total: 300,
            planType: "Monthly",
          ),
          const SizedBox(height: 20),
          _buildPlanCard(
            title: "الاشتراك الاسبوعي",
            duration: "لمدة 7 ايام",
            price: "90ج.م",
            trips: "عدد الرحلات : 5 رحلة",
            total: 90,
            planType: "Weekly",
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String duration,
    required String price,
    required String trips,
    required double total,
    required String planType,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  duration,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  price,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _subscribe(planType, total),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(75),
                      ),
                    ),
                    child: Text(
                      "اشتراك",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 60),
                Text(
                  trips,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _subscribe(String planType, double total) async {
    final accountId = await SessionManager.getAccountId() ?? 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.black)),
    );
    final result = await ApiService().createSubscription(
      accountId: accountId,
      planType: planType,
    );
    if (!mounted) return;
    Navigator.pop(context);
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("تم الاشتراك بنجاح!", style: GoogleFonts.cairo()),
          backgroundColor: Colors.green,
        ),
      );
      _switchView(1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'فشل الاشتراك',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // اشتراكاتي
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMySubscription() {
    if (_isLoading)
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );

    if (_sub == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => _switchView(0),
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
          ),
        ],
      );
    }

    final planType = _sub!['typeSubscription'] ?? _sub!['planType'] ?? '';
    final startDate = _formatDate(_sub!['startDate']);
    final endDate = _formatDate(_sub!['endDate']);
    final discount = _sub!['discountPercentage'] ?? 0;
    final usedTrips = _sub!['usedTrips'] ?? _sub!['tripsUsed'] ?? 0;
    final totalTrips = _sub!['totalTrips'] ?? _sub!['tripsTotal'] ?? 12;
    final isActive = (_sub!['isActive'] ?? true) == true;
    final progress = totalTrips > 0
        ? (usedTrips / totalTrips).clamp(0.0, 1.0)
        : 0.0;

    return RefreshIndicator(
      onRefresh: _loadSubscription,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── زراري التنقل ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36),
                      ),
                    ),
                    child: Text(
                      "اشتراكاتي",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _switchView(0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2F2F2),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36),
                      ),
                    ),
                    child: Text(
                      "الاشتراكات المتاحة",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── كارت الاشتراك ────────────────────────────────────────────────
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "صالح : $startDate  _  $endDate",
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "%الخصم : $discount",
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$totalTrips / $usedTrips",
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "الرحلات المستخدمة",
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
            const SizedBox(height: 30),

            // ── زرار تجديد ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton(
                onPressed: () => _showRenewDialog(planType),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(59),
                  ),
                ),
                child: Text(
                  "تجديد الاشتراك",
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── سجل الاشتراكات ───────────────────────────────────────────────
            GestureDetector(
              onTap: () => _switchView(2),
              child: Text(
                "عرض سجل الاشتراكات",
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenewDialog(String planType) {
    final prices = {
      'Yearly': 1200,
      'Monthly': 300,
      'Weekly': 90,
      'Year': 1200,
      'Month': 300,
      'Week': 90,
    };
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
                const SizedBox(height: 20),
                Text(
                  "سيتم تجديد اشتراكك الحالي بنفس الباقة",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
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
                    const SizedBox(height: 8),
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
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2F2F2),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                    const SizedBox(width: 20),
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
                          if (!mounted) return;
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
