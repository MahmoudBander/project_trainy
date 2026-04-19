import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../tickts/seats_screen.dart';
import '../../../widget/trip_model.dart';

class DetailsScreen extends StatelessWidget {
  static const route = "DetailsScreen";
  final TripDetails tripDetails;
  final int journeyId;

  const DetailsScreen({super.key, required this.tripDetails, this.journeyId = 0});

  Color _badgeColor(String type) {
    switch (type) {
      case 'VIP':  return const Color(0xFFFFD700);
      case 'نوم':  return const Color(0xFF00BCD4);
      case 'سريع': return const Color(0xFF4CAF50);
      default:     return const Color(0xFFFFD700);
    }
  }

  Color _badgeTextColor(String type) => type == 'VIP' ? Colors.black : Colors.white;

  IconData _stationIcon(int index, int total) {
    if (index == 0) return Icons.train;
    if (index == total - 1) return Icons.flag;
    return Icons.location_on;
  }

  @override
  Widget build(BuildContext context) {
    // نحسب ارتفاع الـ status bar + الهيدر
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight    = statusBarHeight + 60;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── خلفية سوداء فوق + بيضاء تحت ──────────────────────────────
          Column(children: [
            Container(height: 200, width: double.infinity, color: Colors.black),
            Expanded(child: Container(width: double.infinity, color: Colors.white)),
          ]),

          // ── هيدر: سهم + عنوان في النص ─────────────────────────────────
          SafeArea(
            child: SizedBox(
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white)),
                  ),
                  Text("تفاصيل الرحلة",
                      style: GoogleFonts.cairo(fontSize: 24,
                          fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),

          // ── الكارت الأبيض ──────────────────────────────────────────────
          Positioned(
            top: headerHeight + 20,
            left: 16, right: 16, bottom: 30,
            child: Column(children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                  color: _badgeColor(tripDetails.tripType),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(tripDetails.tripType,
                                  style: GoogleFonts.cairo(fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _badgeTextColor(tripDetails.tripType))),
                            ),
                            Text(tripDetails.trainName,
                                style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          Text('${tripDetails.from} ← ${tripDetails.to}',
                              style: GoogleFonts.cairo(fontSize: 14)),
                          const SizedBox(width: 6),
                          const Icon(Icons.train, size: 16),
                        ]),
                        const SizedBox(height: 10),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          Text(tripDetails.date,
                              style: GoogleFonts.cairo(fontSize: 14)),
                          const SizedBox(width: 6),
                          const Icon(Icons.calendar_today, size: 16),
                        ]),
                        const SizedBox(height: 24),
                        Text('المخطط الزمني للمحطات',
                            style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        ...List.generate(tripDetails.stations.length, (i) {
                          final station = tripDetails.stations[i];
                          final isLast  = i == tripDetails.stations.length - 1;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(station.name,
                                      style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(station.time,
                                      style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
                                  if (!isLast) const SizedBox(height: 20),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Column(children: [
                                Icon(_stationIcon(i, tripDetails.stations.length),
                                    color: Colors.blue, size: 22),
                                if (!isLast)
                                  Container(width: 2, height: 44,
                                      color: Colors.blue.withOpacity(0.3)),
                              ]),
                            ],
                          );
                        }),
                        const SizedBox(height: 24),
                        Text('انواع التذاكر المتاحة',
                            style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        ...tripDetails.ticketTypes.map((ticket) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(ticket.price,
                                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(ticket.name,
                                      style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 3),
                                  Text(
                                      ticket.discount.isNotEmpty ? ticket.discount : ticket.description,
                                      style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 65,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => Seatsscreen(
                        journeyId: journeyId,
                        tripDetails: tripDetails,
                      ))),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(59))),
                  child: Text("احجز تذكرة",
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700,
                          fontSize: 28, color: Colors.white)),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
