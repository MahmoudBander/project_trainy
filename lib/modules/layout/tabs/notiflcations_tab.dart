import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/core/session_manager.dart';

import '../home.dart';

class NotiflcationsTab extends StatefulWidget {
  const NotiflcationsTab({super.key});

  @override
  State<NotiflcationsTab> createState() => _NotiflcationsTabState();
}

class _NotiflcationsTabState extends State<NotiflcationsTab> {
  List<dynamic> _notifications = [];
  bool          _isLoading     = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final accountId = await SessionManager.getAccountId() ?? 0;
    final result    = await ApiService().getNotifications(accountId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true && result['data'] != null) {
          _notifications = result['data'] as List;
        }
      });
    }
  }

  Future<void> _deleteNotification(int notificationId, int index) async {
    final result = await ApiService().deleteNotification(notificationId);
    if (result['success'] == true && mounted) {
      setState(() => _notifications.removeAt(index));
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60)  return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inHours < 24)    return 'منذ ${diff.inHours} ساعة';
      if (diff.inDays == 1)     return 'منذ يوم';
      return 'منذ ${diff.inDays} أيام';
    } catch (_) {
      return dateStr;
    }
  }

  IconData _iconFor(String? type) {
    final t = (type ?? '').toLowerCase();
    if (t.contains('pay') || t.contains('دفع'))    return Icons.payment_rounded;
    if (t.contains('train') || t.contains('رحلة')) return Icons.train;
    if (t.contains('cancel') || t.contains('الغ')) return Icons.cancel_outlined;
    return Icons.notifications_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 160, width: double.infinity, color: Colors.white,
                child: Stack(
                  children: [
                    Positioned(left: 16, bottom: 30,
                      child: IconButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context, Home.route, (route) => false, arguments: 4),
                        icon: const Icon(Icons.arrow_back),
                        iconSize: 24, color: Colors.black)),
                    Positioned(left: 0, right: 0, bottom: 40,
                      child: Center(child: Text('الاشعارات',
                        style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700)))),
                  ],
                ),
              ),
              Container(height: 1, width: double.infinity, color: Colors.grey[300]),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.black))
                    : _notifications.isEmpty
                        ? Center(child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text("لا توجد إشعارات",
                                style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey.shade500)),
                            ],
                          ))
                        : RefreshIndicator(
                            onRefresh: _loadNotifications,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                      Text("الإشعارات",
                                        style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700)),
                                    ]),
                                    const SizedBox(height: 10),
                                    ...List.generate(_notifications.length, (i) {
                                      final n          = _notifications[i];
                                      final title      = n['title']   ?? n['type']    ?? 'إشعار';
                                      final message    = n['message'] ?? n['content'] ?? '';
                                      final createdAt  = n['createdAt'] ?? n['date']  ?? '';
                                      final notifId    = n['notificationId'] ?? n['id'] ?? 0;

                                      return Column(
                                        children: [
                                          Dismissible(
                                            key: Key('notif_$notifId'),
                                            direction: DismissDirection.endToStart,
                                            background: Container(
                                              alignment: Alignment.centerRight,
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              color: Colors.red,
                                              child: const Icon(Icons.delete, color: Colors.white),
                                            ),
                                            onDismissed: (_) => _deleteNotification(notifId, i),
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(38),
                                                border: Border.all(color: Colors.white, width: 1),
                                                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 7, offset: const Offset(0, 4))],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: Column(
                                                  children: [
                                                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                      Text(title,
                                                        style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black)),
                                                      const SizedBox(width: 5),
                                                      Icon(_iconFor(title), size: 35),
                                                    ]),
                                                    if (message.isNotEmpty) ...[
                                                      const SizedBox(height: 5),
                                                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                        Flexible(child: Text(message,
                                                          textAlign: TextAlign.right,
                                                          style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey))),
                                                      ]),
                                                    ],
                                                    const SizedBox(height: 20),
                                                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                                      Text(_formatTime(createdAt),
                                                        style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey)),
                                                    ]),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
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
