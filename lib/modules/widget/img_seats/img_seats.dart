import 'package:flutter/material.dart';

// 1. الموديل الخاص بالبيانات
class SeatModel {
  final String label;
  final bool isReserved;
  bool isSelected;

  SeatModel({
    required this.label,
    this.isReserved = false,
    this.isSelected = false,
  });
}

class ImgSeats extends StatefulWidget {
  final Function(List<String>)? onSeatsSelected;
  final List<int> reservedSeats; // أرقام الكراسي المحجوزة من الـ API

  const ImgSeats({super.key, this.onSeatsSelected, this.reservedSeats = const []});

  @override
  State<ImgSeats> createState() => _ImgSeatsState();
}

class _ImgSeatsState extends State<ImgSeats> {
  late List<SeatModel?> allSeats;

  @override
  void initState() {
    super.initState();
    _initSeatData();
  }

  void _initSeatData() {
    List<SeatModel?> tempSeats = [];
    List<String> columns = ['A', 'B', 'C', 'D'];

    // الكراسي المحجوزة — من الـ API لو موجودة، وإلا fallback للـ hardcoded
    List<String> reservedLabels = widget.reservedSeats.isNotEmpty
        ? widget.reservedSeats.map((n) {
            // تحويل رقم الكرسي لـ label مثل A1, B2
            int row    = ((n - 1) ~/ 4) + 1;
            int colIdx = (n - 1) % 4;
            List<String> cols = ['A', 'B', 'C', 'D'];
            return '${cols[colIdx]}$row';
          }).toList()
        : ['B1', 'C2', 'A3', 'B5', 'B6', 'C7', 'D7'];

    for (int row = 1; row <= 7; row++) {
      for (int colIndex = 0; colIndex < 5; colIndex++) {
        if (colIndex == 2) {
          tempSeats.add(null);
        } else {
          String char = columns[colIndex > 2 ? colIndex - 1 : colIndex];
          String currentLabel = '$char$row';
          tempSeats.add(SeatModel(
            label: currentLabel,
            isReserved: reservedLabels.contains(currentLabel),
          ));
        }
      }
    }
    allSeats = tempSeats;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allSeats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10, // زيادة المسافة الرأسية قليلاً للوضوح
        crossAxisSpacing: 10, // زيادة المسافة الأفقية قليلاً للوضوح
      ),
      itemBuilder: (context, index) {
        if (allSeats[index] == null) {
          int rowNum = (index ~/ 5) + 1;
          return Center(
            child: Text(
              "$rowNum",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        }

        final seat = allSeats[index]!;
        return _buildSeatItem(seat);
      },
    );
  }

  Widget _buildSeatItem(SeatModel seat) {
    // تحديد مسار الصورة بناءً على الحالة
    String imageAsset = 'assets/images/seats_img/seat_grey.png';
    if (seat.isReserved) {
      imageAsset = 'assets/images/seats_img/seat_red.png';
    } else if (seat.isSelected) {
      imageAsset = 'assets/images/seats_img/seat_blue.png';
    }

    return GestureDetector(
      onTap: () {
        if (!seat.isReserved) {
          setState(() {
            seat.isSelected = !seat.isSelected;
          });

          if (widget.onSeatsSelected != null) {
            List<String> selected = allSeats
                .where((s) => s != null && s.isSelected)
                .map((s) => s!.label)
                .toList();
            widget.onSeatsSelected!(selected);
          }
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(imageAsset, fit: BoxFit.contain),
          // التعديل الجديد لجعل الرقم أكبر وأوضح
          Positioned(
            top: 8, // ضبط الإزاحة العلوية ليكون في منتصف مساحة الكرسي المخصصة للنص
            child: Text(
              seat.label,
              style: const TextStyle(
                fontSize: 16, // تكبير حجم الخط لزيادة الوضوح
                fontWeight: FontWeight.w600, // خط عريض جداً ليظهر بوضوح فوق الصورة
                color: Colors.black, // لون أسود صريح
                letterSpacing: -0.5, // تقريب الحروف قليلاً ليتناسب مع عرض الكرسي
              ),
            ),
          ),
        ],
      ),
    );
  }
}