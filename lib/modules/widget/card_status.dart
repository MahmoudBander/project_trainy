import 'package:flutter/material.dart';

class CardStatus extends StatelessWidget {
  final String       status;
  final String       detals;
  final String       category;
  final bool         selected;
  final VoidCallback onTap;

  const CardStatus({
    super.key,
    required this.status,
    required this.detals,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 1, offset: const Offset(1, 5))],
            border: Border.all(color: Colors.grey.shade50),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_box : Icons.check_box_outline_blank,
                color: Colors.black,
                size: 28,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(status,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                          fontFamily: "Cairo", color: Colors.black)),
                  Text(detals,
                      style: const TextStyle(fontSize: 16, fontFamily: "Cairo",
                          fontWeight: FontWeight.w400, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
