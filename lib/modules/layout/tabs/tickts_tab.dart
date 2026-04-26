import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:project_bander/modules/tickts/q_r_screen.dart';
import 'package:project_bander/modules/tickts/confirmation_recovery_screen/recovery_screen.dart';

import '../../tickts/tickets_storage/tickets_storage.dart';
import '../home.dart';

class TicktsTab extends StatefulWidget {
  static const route = "TicktsTab";
  const TicktsTab({super.key});

  @override
  State<TicktsTab> createState() => _TicktsTabState();
}

class _TicktsTabState extends State<TicktsTab> {
  String selectedTab = 'القادمة';
  bool _isLoading = true;

  List<Map<String, dynamic>> _allTickets = [];
  List<Map<String, dynamic>> upcomingTickets = [];
  List<Map<String, dynamic>> completedTickets = [];
  List<Map<String, dynamic>> cancelledTickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);

    // ── جيب من الـ API ────────────────────────────────────────────────
    final accountId = await SessionManager.getAccountId() ?? 0;
    final result = await ApiService().myTickets(accountId);

    upcomingTickets = [];
    completedTickets = [];
    cancelledTickets = [];

    if (result['success'] == true && result['data'] != null) {
      _allTickets = List<Map<String, dynamic>>.from(result['data']);
      _categorize();
    }

    // ── جيب من الـ local storage ──────────────────────────────────────
    final localTickets = await TicketsStorage.getAll();

    if (mounted) {
      setState(() {
        _isLoading = false;
        for (final t in localTickets) {
          final card = {
            'ticketId': t.ticketId,
            'status': t.status == 'upcoming'
                ? 'قادمة'
                : t.status == 'completed'
                ? 'مكتملة'
                : 'ملغاة',
            'route': '${t.fromStation} ← ${t.toStation}',
            'date': t.tripDate,
            'departure': t.departure,
            'price': '${t.ticketPrice.toStringAsFixed(0)} ج.م',
            'seatInfo': 'مقعد ${t.seatNumber}',
            'trainName': t.trainName,
            'statusColor': t.status == 'upcoming'
                ? const Color(0xffBF810E)
                : t.status == 'completed'
                ? Colors.green
                : Colors.red,
            'statusBgColor': t.status == 'upcoming'
                ? const Color(0xFFEFFF33).withOpacity(0.4)
                : t.status == 'completed'
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
          };
          // تجنب التكرار مع الـ API tickets
          // تجاهل التذاكر الفاضية
          if (t.fromStation.isEmpty || t.toStation.isEmpty) continue;
          if (t.status == 'upcoming' &&
              !upcomingTickets.any((x) => x['ticketId'] == t.ticketId)) {
            upcomingTickets.insert(0, card);
          } else if (t.status == 'completed' &&
              !completedTickets.any((x) => x['ticketId'] == t.ticketId)) {
            completedTickets.insert(0, card);
          } else if (t.status == 'cancelled' &&
              !cancelledTickets.any((x) => x['ticketId'] == t.ticketId)) {
            cancelledTickets.insert(0, card);
          }
        }
      });
    }
  }

  void _categorize() {
    upcomingTickets = [];
    completedTickets = [];
    cancelledTickets = [];

    for (final t in _allTickets) {
      final status = (t['status'] ?? t['ticketStatus'] ?? '')
          .toString()
          .toLowerCase();
      if (status.contains('cancel') || status.contains('الغ')) {
        cancelledTickets.add(
          _toCard(t, 'ملغاة', Colors.red, Colors.red.withOpacity(0.1)),
        );
      } else if (status.contains('complet') || status.contains('مكتمل')) {
        completedTickets.add(
          _toCard(t, 'مكتملة', Colors.green, Colors.green.withOpacity(0.2)),
        );
      } else {
        final card = _toCard(
          t,
          'قادمة',
          const Color(0xffBF810E),
          const Color(0xFFEFFF33).withOpacity(0.4),
        );
        if (card['route'] != '--- ← ---') upcomingTickets.add(card);
      }
    }
  }

  Map<String, dynamic> _toCard(
    Map t,
    String statusLabel,
    Color sColor,
    Color sBg,
  ) {
    final journey = t['journey'] ?? {};
    final fromStation =
        journey['fromStation']?['stationName'] ?? journey['from'] ?? '---';
    final toStation =
        journey['toStation']?['stationName'] ?? journey['to'] ?? '---';
    final trainName =
        journey['train']?['trainName'] ?? journey['trainName'] ?? 'قطار';
    final departure = journey['departureTime'] ?? '';
    final price = t['price'] ?? journey['price'] ?? 0;
    final seatNumber = t['seatNumber'] ?? '---';
    final ticketId = t['ticketId'] ?? t['id'] ?? 0;

    return {
      'ticketId': ticketId,
      'status': statusLabel,
      'route': '$fromStation ← $toStation',
      'date': departure.split('T').first,
      'departure': departure.contains('T')
          ? departure.split('T').last.substring(0, 5)
          : departure,
      'price': '$price ج.م',
      'seatInfo': 'مقعد $seatNumber',
      'trainName': trainName,
      'statusColor': sColor,
      'statusBgColor': sBg,
    };
  }

  List<Map<String, dynamic>> getCurrentTickets() {
    if (selectedTab == 'القادمة') return upcomingTickets;
    if (selectedTab == 'المكتملة') return completedTickets;
    return cancelledTickets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: Column(
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
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Home.route,
                            (route) => false, // بيمسح الصفحات اللي فاتت عشان يظهر البوتوم بار كأنك لسه داخل
                        arguments: 4,     // رقم 3 هو الـ Index بتاع صفحة "تذاكري" في الـ list بتاعتك
                      );
                    },
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 40,
                  child: Center(
                    child: Text(
                      'تذاكري',
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabButton('الملغاة'),
                const SizedBox(width: 10),
                _buildTabButton('المكتملة'),
                const SizedBox(width: 10),
                _buildTabButton('القادمة'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  )
                : getCurrentTickets().isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          selectedTab == 'القادمة'
                              ? 'لا توجد تذاكر قادمة'
                              : selectedTab == 'المكتملة'
                              ? 'لا توجد تذاكر مكتملة'
                              : 'لا توجد تذاكر ملغاة',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTickets,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: getCurrentTickets().length,
                      itemBuilder: (context, index) {
                        final ticket = getCurrentTickets()[index];
                        return _buildTicketCard(ticket);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    bool isSelected = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade400,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          // ── التعديل الوحيد: أضفنا Flexible على نص المحطات ──────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: ticket['statusBgColor'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ticket['status'],
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ticket['statusColor'],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  ticket['route'],
                  textAlign: TextAlign.end,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticket['departure'] ?? '',
                style: GoogleFonts.cairo(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                ticket['date'],
                style: GoogleFonts.cairo(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "سعر التذكرة",
                    style: GoogleFonts.cairo(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.price_change_rounded,
                    color: Color(0xFF0A7A82),
                    size: 20,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "المقعد",
                    style: GoogleFonts.cairo(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.event_seat_rounded,
                    color: Color(0xFF0A7A82),
                    size: 20,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "القطار",
                    style: GoogleFonts.cairo(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.train, color: Color(0xFF0A7A82), size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticket['price'],
                style: GoogleFonts.cairo(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ticket['seatInfo'],
                style: GoogleFonts.cairo(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                ticket['trainName'],
                style: GoogleFonts.cairo(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (ticket['status'] == 'قادمة')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RecoveryScreen(ticketId: ticket['ticketId'] ?? 0),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      elevation: 2,
                      shadowColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                    child: Text(
                      "الغاء",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              if (ticket['status'] == 'قادمة') const SizedBox(width: 80),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QRScreen(ticketId: ticket['ticketId']),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(75),
                    ),
                  ),
                  child: Text(
                    "تفاصيل",
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
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
