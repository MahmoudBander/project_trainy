import 'package:flutter/material.dart';
import 'package:project_bander/core/session_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/modules/widget/trip_model.dart';
import '../widget/img_seats/img_seats.dart';
import 'confirmation_screen.dart';

class Seatsscreen extends StatefulWidget {
  final int journeyId;
  final TripDetails tripDetails;

  const Seatsscreen({super.key, required this.journeyId, required this.tripDetails});

  @override
  State<Seatsscreen> createState() => _SeatsscreenState();
}

class _SeatsscreenState extends State<Seatsscreen> {
  List<String> selectedSeats  = [];
  List<int>    reservedSeats  = [];
  bool         _loadingSeats  = true;

  @override
  void initState() {
    super.initState();
    _loadReservedSeats();
  }

  Future<void> _loadReservedSeats() async {
    final result = await ApiService().getReservedSeats(widget.journeyId);
    if (mounted) {
      setState(() {
        _loadingSeats = false;
        if (result['success'] == true && result['data'] != null) {
          reservedSeats = List<int>.from(
              (result['data'] as List).map((s) => s['seatNumber'] ?? s).whereType<int>()
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(children: [
            Container(height: 200, width: double.infinity, color: Colors.black),
            Expanded(child: Container(width: double.infinity, color: Colors.white)),
          ]),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 75),
                Text("اختر مقعدك",
                    style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            ),
          ),
          Positioned(
            top: 140, left: 16, right: 16, bottom: 40,
            child: Column(
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: _loadingSeats
                          ? const Center(child: CircularProgressIndicator(color: Colors.black))
                          : SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildClassItem("درجة اولي", true),
                                buildClassItem("درجة ثانية", false),
                                buildClassItem("عربة نوم", false),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                buildLegend("متاح",  const Color(0xffBEB3B3)),
                                buildLegend("مختار", const Color(0xff361AAE)),
                                buildLegend("محجوز", const Color(0xffD70D0D)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ImgSeats(
                              reservedSeats: reservedSeats,
                              onSeatsSelected: (List<String> list) {
                                setState(() { selectedSeats = list; });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 394,
                  height: 72,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedSeats.isNotEmpty) {
                        // احفظ بيانات الرحلة كاملة
                        await SessionManager.saveTripData(
                          fromStation: widget.tripDetails.from,
                          toStation:   widget.tripDetails.to,
                          departure:   widget.tripDetails.stations.isNotEmpty ? widget.tripDetails.stations.first.time : '',
                          arrival:     widget.tripDetails.stations.length > 1  ? widget.tripDetails.stations.last.time  : '',
                          trainName:   widget.tripDetails.trainName,
                          tripDate:    widget.tripDetails.date,
                          seatNumber:  selectedSeats.join(', '),
                        );
                        if (!context.mounted) return;
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ConfirmationScreen(
                            selectedSeats: selectedSeats,
                            journeyId:    widget.journeyId,
                            tripDetails:  widget.tripDetails,
                          ),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("برجاء اختيار مقعد أولاً", textAlign: TextAlign.right)));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(59)),
                    ),
                    child: Text("تأكيد الاختيار",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 32, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildClassItem(String text, bool isSelected) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      color: isSelected ? Colors.black : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(25),
    ),
    child: Text(text,
        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : Colors.black)),
  );

  Widget buildLegend(String text, Color color) => Row(children: [
    CircleAvatar(radius: 15, backgroundColor: color),
    const SizedBox(width: 12),
    Text(text, style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w400)),
  ]);
}
