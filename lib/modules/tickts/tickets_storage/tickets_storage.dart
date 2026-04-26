import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TicketModel {
  final int    ticketId;
  final String fromStation;
  final String toStation;
  final String trainName;
  final String tripDate;
  final String departure;
  final String arrival;
  final String seatNumber;
  final double ticketPrice;
  String       status; // 'upcoming' | 'completed' | 'cancelled'
  final DateTime createdAt;

  TicketModel({
    required this.ticketId,
    required this.fromStation,
    required this.toStation,
    required this.trainName,
    required this.tripDate,
    required this.departure,
    required this.arrival,
    required this.seatNumber,
    required this.ticketPrice,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'ticketId':    ticketId,
    'fromStation': fromStation,
    'toStation':   toStation,
    'trainName':   trainName,
    'tripDate':    tripDate,
    'departure':   departure,
    'arrival':     arrival,
    'seatNumber':  seatNumber,
    'ticketPrice': ticketPrice,
    'status':      status,
    'createdAt':   createdAt.toIso8601String(),
  };

  factory TicketModel.fromJson(Map<String, dynamic> j) => TicketModel(
    ticketId:    j['ticketId']    ?? 0,
    fromStation: j['fromStation'] ?? '',
    toStation:   j['toStation']   ?? '',
    trainName:   j['trainName']   ?? '',
    tripDate:    j['tripDate']    ?? '',
    departure:   j['departure']   ?? '',
    arrival:     j['arrival']     ?? '',
    seatNumber:  j['seatNumber']  ?? '',
    ticketPrice: (j['ticketPrice'] ?? 0).toDouble(),
    status:      j['status']      ?? 'upcoming',
    createdAt:   DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );

  // هل وقت القطار عدى؟
  bool get isExpired {
    try {
      // حاول تحلل التاريخ مع الوقت
      final dateStr = tripDate;
      final depStr  = departure; // "وقت المغادرة 10:00 صباحاً"

      // استخرج الوقت من النص
      final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(depStr);
      int hour   = 0;
      int minute = 0;
      if (timeMatch != null) {
        hour   = int.parse(timeMatch.group(1)!);
        minute = int.parse(timeMatch.group(2)!);
        if (depStr.contains('مساء') && hour != 12) hour += 12;
        if (depStr.contains('صباح') && hour == 12) hour = 0;
      }

      final date     = DateTime.parse(dateStr);
      final tripTime = DateTime(date.year, date.month, date.day, hour, minute);
      return tripTime.isBefore(DateTime.now());
    } catch (_) {
      try {
        return DateTime.parse(tripDate).isBefore(DateTime.now());
      } catch (_) { return false; }
    }
  }
}

class TicketsStorage {
  static const _key = 'saved_tickets';

  // ── جيب كل التذاكر ──────────────────────────────────────────────────
  static Future<List<TicketModel>> getAll() async {
    final p    = await SharedPreferences.getInstance();
    final json = p.getString(_key);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    final tickets = list.map((e) => TicketModel.fromJson(e)).toList();

    // تحديث تلقائي للتذاكر المنتهية
    bool changed = false;
    for (final t in tickets) {
      if (t.status == 'upcoming' && t.isExpired) {
        t.status = 'completed';
        changed  = true;
      }
    }
    if (changed) await _saveAll(tickets);
    return tickets;
  }

  // ── أضف تذكرة جديدة ─────────────────────────────────────────────────
  static Future<void> add(TicketModel ticket) async {
    final tickets = await getAll();
    // تجنب التكرار
    tickets.removeWhere((t) => t.ticketId == ticket.ticketId && ticket.ticketId != 0);
    tickets.insert(0, ticket);
    await _saveAll(tickets);
  }

  // ── غير حالة تذكرة ──────────────────────────────────────────────────
  static Future<void> updateStatus(int ticketId, String newStatus) async {
    final tickets = await getAll();
    for (final t in tickets) {
      if (t.ticketId == ticketId) t.status = newStatus;
    }
    await _saveAll(tickets);
  }

  // ── احفظ الكل ───────────────────────────────────────────────────────
  static Future<void> _saveAll(List<TicketModel> tickets) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(tickets.map((t) => t.toJson()).toList()));
  }

  // ── فلتر حسب الحالة ─────────────────────────────────────────────────
  static Future<List<TicketModel>> getByStatus(String status) async {
    final all = await getAll();
    return all.where((t) => t.status == status).toList();
  }
}
