import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/api/api_handler.dart';
import '../../../widget/trip_model.dart' as trip_model;
import '../../home.dart';
import 'details_screen.dart';

class AvailableFlights extends StatefulWidget {
  final ApiStation  fromStation;
  final ApiStation  toStation;
  final String      departureDate;
  final VoidCallback? onBack;
  final double discountPercent;

  const AvailableFlights({
    super.key,
    required this.fromStation,
    required this.toStation,
    required this.departureDate,
    this.onBack,
    this.discountPercent = 0,
  });

  @override
  State<AvailableFlights> createState() => _AvailableFlightsState();
}

class _AvailableFlightsState extends State<AvailableFlights> {
  bool _isLoading = true;
  late final List<Map<String, dynamic>> _journeys;

  @override
  void initState() {
    super.initState();
    final from = widget.fromStation.stationName;
    final to   = widget.toStation.stationName;

    _journeys = [
      {
        'trainName':     'قطار النيل السريع',
        'trainType':     'VIP',
        'departureTime': '10:00ص',
        'arrivalTime':   '8:00م',
        'duration':      '10 ساعات',
        'price':         '150-300',
        'seats':         '25 مقعد متاح',
        'from':          from,
        'to':            to,
        'badgeColor':    const Color(0xFFFFD700),
        'textColor':     const Color(0xFF000000),
        'ticketTypes': [
          trip_model.TicketType(name: 'درجة أولى',  description: 'درجة أولى VIP', price: '\$150'),
          trip_model.TicketType(name: 'درجة ثانية', description: 'مقاعد مريحة',           price: '\$100'),
        ],
        'stations': [
          trip_model.Station(name: 'محطة $from', time: 'وقت المغادرة 10:00 صباحاً', isDeparture: true),
          trip_model.Station(name: 'محطة وسط الطريق', time: 'وقت التوقف 2:00 مساءاً',  isDeparture: false),
          trip_model.Station(name: 'محطة $to',   time: 'وقت الوصول 8:00 مساءاً',   isDeparture: false),
        ],
      },
      {
        'trainName':     'رحلة الصحراء',
        'trainType':     'نوم',
        'departureTime': '10:00ص',
        'arrivalTime':   '8:00م',
        'duration':      '10 ساعات',
        'price':         '250-250',
        'seats':         '15 مقعد متاح',
        'from':          from,
        'to':            to,
        'badgeColor':    const Color(0xFF00BCD4),
        'textColor':     const Color(0xFFFFFFFF),
        'ticketTypes': [
          trip_model.TicketType(name: 'درجة نوم',   description: 'كابينة خاصة',   price: '\$250'),
          trip_model.TicketType(name: 'درجة أولى',  description: 'مقاعد مريحة',   price: '\$200'),
        ],
        'stations': [
          trip_model.Station(name: 'محطة $from',         time: 'وقت المغادرة 10:00 صباحاً', isDeparture: true),
          trip_model.Station(name: 'محطة وسط الطريق',   time: 'وقت التوقف 2:00 مساءاً',    isDeparture: false),
          trip_model.Station(name: 'محطة $to',           time: 'وقت الوصول 8:00 مساءاً',   isDeparture: false),
        ],
      },
      {
        'trainName':     'سريع البحر الاحمر',
        'trainType':     'سريع',
        'departureTime': '10:00ص',
        'arrivalTime':   '5:00م',
        'duration':      '7 ساعات',
        'price':         '80-180',
        'seats':         '30 مقعد متاح',
        'from':          from,
        'to':            to,
        'badgeColor':    const Color(0xFF4CAF50),
        'textColor':     const Color(0xFFFFFFFF),
        'ticketTypes': [
          trip_model.TicketType(name: 'درجة أولى',  description: 'مقاعد واسعة',  price: '\$180'),
          trip_model.TicketType(name: 'درجة ثانية', description: 'مقاعد عادية',  price: '\$80'),
        ],
        'stations': [
          trip_model.Station(name: 'محطة $from',         time: 'وقت المغادرة 10:00 صباحاً', isDeparture: true),
          trip_model.Station(name: 'محطة وسط الطريق',   time: 'وقت التوقف 1:00 مساءاً',    isDeparture: false),
          trip_model.Station(name: 'محطة $to',           time: 'وقت الوصول 5:00 مساءاً',   isDeparture: false),
        ],
      },
    ];

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () { if (widget.onBack != null) { widget.onBack!(); } else { Navigator.pop(context); } },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text("الرحلات المتاحة",
                    style: GoogleFonts.cairo(fontSize: 36, fontWeight: FontWeight.bold)),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${widget.fromStation.stationName} ← ${widget.toStation.stationName}  •  ${widget.departureDate}",
                  style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _filterChip("نوع القطار"), const SizedBox(width: 8),
                  _filterChip("الفئة"),      const SizedBox(width: 8),
                  _filterChip("الوقت"),      const SizedBox(width: 8),
                  _filterChip("السعر"),
                ]),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.black))
                    : ListView.separated(
                  itemCount: _journeys.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) => _buildJourneyCard(_journeys[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJourneyCard(Map<String, dynamic> j) {
    final from       = j['from']          as String;
    final to         = j['to']            as String;
    final trainName  = j['trainName']     as String;
    final trainType  = j['trainType']     as String;
    final departure  = j['departureTime'] as String;
    final arrival    = j['arrivalTime']   as String;
    final duration   = j['duration']      as String;
    final price      = j['price']         as String;
    final seats      = j['seats']         as String;
    final badgeColor = j['badgeColor']    as Color;
    final textColor  = j['textColor']     as Color;
    final rawTicketTypes = j['ticketTypes'] as List<trip_model.TicketType>;
    // الخصم بييجي بس من شاشة الحالة
    final ticketTypes = widget.discountPercent > 0
        ? rawTicketTypes.map((t) => trip_model.TicketType(
      name: t.name,
      description: t.description,
      price: t.price,
      discount: widget.discountPercent.toInt().toString(),
    )).toList()
        : rawTicketTypes.map((t) => trip_model.TicketType(
      name: t.name,
      description: t.description,
      price: t.price,
      discount: '',
    )).toList();
    final stations    = j['stations']     as List<trip_model.Station>;

    final tripDetails = trip_model.TripDetails(
      trainName:   trainName,
      tripType:    trainType,
      from:        from,
      to:          to,
      date:        widget.departureDate,
      stations:    stations,
      ticketTypes: ticketTypes,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                    color: badgeColor, borderRadius: BorderRadius.circular(10)),
                child: Text(trainType,
                    style: GoogleFonts.cairo(fontSize: 15,
                        fontWeight: FontWeight.w700, color: textColor)),
              ),
              const SizedBox(height: 55),
              SizedBox(
                width: 110, height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) =>
                          DetailsScreen(tripDetails: tripDetails, journeyId: 0))),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(75))),
                  child: Text("تفاصيل",
                      style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(trainName,
                    style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right),
                const SizedBox(height: 8),
                Text("$from ($departure) ← $to ($arrival)",
                    style: GoogleFonts.cairo(fontSize: 13, color: Colors.black87),
                    textAlign: TextAlign.right),
                const SizedBox(height: 4),
                Text("المدة $duration",
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.right),
                const SizedBox(height: 8),
                Text("$price ج.م",
                    style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right),
                const SizedBox(height: 4),
                Text(seats,
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.right),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1)),
    child: Row(children: [
      const Icon(Icons.keyboard_arrow_down, size: 18),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700)),
    ]),
  );
}
