import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/modules/tickts/q_r_screen.dart';

class BookedScreen extends StatefulWidget {
  final List<int> ticketIds;

  const BookedScreen({super.key, required this.ticketIds});

  @override
  State<BookedScreen> createState() => _BookedScreenState();
}

class _BookedScreenState extends State<BookedScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => QRScreen(ticketId: widget.ticketIds.isNotEmpty ? widget.ticketIds.first : 0)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset("assets/images/icons/5965208742762581546.jpg", width: 90, height: 90),
                Image.asset("assets/images/icons/5965208742762581545.jpg", width: 50, height: 50),
              ],
            ),
            const SizedBox(height: 30),
            Text("!تم الحجز بنجاح",
                style: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.black)),
            const SizedBox(height: 10),
            Text("تمت اضافة تذكرتك الي تذاكري",
                style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w400)),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
