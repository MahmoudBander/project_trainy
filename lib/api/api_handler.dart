import 'package:dio/dio.dart';
import 'package:project_bander/core/session_manager.dart';

// ── ApiStation (renamed to avoid conflict with trip_model.Station) ────────────
class ApiStation {
  final int    stationId;
  final String stationName;
  final String location;

  ApiStation({required this.stationId, required this.stationName, required this.location});

  factory ApiStation.fromJson(Map<String, dynamic> json) => ApiStation(
    stationId:   json['stationId']   ?? 0,
    stationName: json['stationName'] ?? '',
    location:    json['location']    ?? '',
  );
}

// ── ApiService ────────────────────────────────────────────────────────────────
class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl:        'http://trainbookingsysteam.runasp.net/api',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ));

  Future<Options> _auth() async {
    final t = await SessionManager.getToken();
    return Options(headers: {'Authorization': 'Bearer $t'});
  }

  Map<String,dynamic> _ok(dynamic data) => {'success': true,  'data': data};
  Map<String,dynamic> _err(String msg)  => {'success': false, 'message': msg, 'data': null};

  // ── AUTH ──────────────────────────────────────────────────────────────────
  Future<Map<String,dynamic>> login({required String email, required String password}) async {
    try { final r = await _dio.post('/Accounts/Login', data: {'email':email,'password':password}); return _ok(r.data); }
    on DioException catch (e) { return {'success':false,'message':_e(e),'data':e.response?.data}; }
    catch(e){ return _err(e.toString()); }
  }

  Future<Map<String,dynamic>> register({required String name, required String email, required String password, required String phone}) async {
    try { final r = await _dio.post('/Accounts/Register', data: {'name':name,'email':email,'password':password,'phone':phone}); return _ok(r.data); }
    on DioException catch (e) { return {'success':false,'message':_e(e),'data':e.response?.data}; }
    catch(e){ return _err(e.toString()); }
  }

  // ── STATIONS ──────────────────────────────────────────────────────────────
  Future<Map<String,dynamic>> getAllStations() async {
    try {
      final r = await _dio.get('/Stations');
      final list = (r.data as List).map((i) => ApiStation.fromJson(i)).toList();
      return _ok(list);
    }
    on DioException catch (e) { return _err(_e(e)); }
    catch(e){ return _err(e.toString()); }
  }

  // ── JOURNEYS ──────────────────────────────────────────────────────────────
  Future<Map<String,dynamic>> searchJourney({
    required String fromStation,
    required String toStation,
    required String date,
    String trainName = '',
  }) async {
    try {
      final r = await _dio.post('/Journeys/SearchJourney', data: {
        'FromStation': fromStation,
        'ToStation':   toStation,
        'TrainName':   trainName,
        'date':        date,
      });
      return _ok(r.data);
    }
    on DioException catch (e) { return _err(_e(e)); }
    catch(e){ return _err(e.toString()); }
  }

  // ── BOOKING ───────────────────────────────────────────────────────────────
  Future<Map<String,dynamic>> createTicket({required int journeyId, required int seatNumber, required int accountId}) async {
    try { final r = await _dio.post('/Booking/CreateTicket', data: {'journeyId':journeyId,'seatNumber':seatNumber,'accountId':accountId}, options: await _auth()); return _ok(r.data); }
    on DioException catch (e) { return {'success':false,'message':_e(e),'data':e.response?.data}; }
    catch(e){ return _err(e.toString()); }
  }

  Future<Map<String,dynamic>> myTickets(int accountId) async {
    try { final r = await _dio.get('/Booking/MyTickets/$accountId', options: await _auth()); return _ok(r.data); }
    on DioException catch (e) { return _err(_e(e)); }
    catch(e){ return _err(e.toString()); }
  }

  Future<Map<String,dynamic>> getReservedSeats(int journeyId) async {
    try { final r = await _dio.get('/Booking/ReservedSeats/$journeyId'); return _ok(r.data); }
    on DioException catch (e) { return _err(_e(e)); }
    catch(e){ return _err(e.toString()); }
  }

  Future<Map<String,dynamic>> cancelTicket({required int ticketId, required String reason}) async {
    try { final r = await _dio.post('/Booking/CancelTicket', data: {'ticketId':ticketId,'reason':reason}, options: await _auth()); return _ok(r.data); }
    on DioException catch (e) { return {'success':false,'message':_e(e),'data':e.response?.data}; }
    catch(e){ return _err(e.toString()); }
  }

  // ── PAYMENT ───────────────────────────────────────────────────────────────
  Future<Map<String,dynamic>> payTicket(int ticketId) async {
    try { final r = await _dio.post('/Payment/$ticketId', options: await _auth()); return _ok(r.data); }
    on DioException catch (e) { return {'success':false,'message':_e(e),'data':e.response?.data}; }
    catch(e){ return _err(e.toString()); }
  }

  // ── NOTIFICATIONS ─────────────────────────────────────────────────────────
  Future<Map<String,dynamic>> getNotifications(int accountId) async {
    try { final r = await _dio.get('/Notifications/$accountId', options: await _auth()); return _ok(r.data); }
    on DioException catch (e) { return _err(_e(e)); }
    catch(e){ return _err(e.toString()); }
  }

  Future<Map<String,dynamic>> deleteNotification(int notificationId) async {
    try { final r = await _dio.delete('/Notifications/$notificationId', options: await _auth()); return _ok(r.data); }
    on DioException catch (e) { return _err(_e(e)); }
    catch(e){ return _err(e.toString()); }
  }

  // ── SUBSCRIPTIONS ─────────────────────────────────────────────────────────
  Future<Map<String,dynamic>> createSubscription({required int accountId, required String planType}) async {
    try { final r = await _dio.post('/Subscriptions', data: {'accountId':accountId,'TypeSubscription':planType}); return _ok(r.data); }
    on DioException catch (e) { return {'success':false,'message':_e(e),'data':e.response?.data}; }
    catch(e){ return _err(e.toString()); }
  }

  Future<Map<String,dynamic>> getSubscription(int accountId) async {
    try { final r = await _dio.get('/Subscriptions/$accountId'); return _ok(r.data); }
    on DioException catch (e) {
      if (e.response?.statusCode == 404) return _ok(null);
      return _err(_e(e));
    }
    catch(e){ return _err(e.toString()); }
  }

  Future<Map<String,dynamic>> cancelSubscription(int subscriptionId) async {
    try { final r = await _dio.post('/Subscriptions/cancel/$subscriptionId'); return _ok(r.data); }
    on DioException catch (e) { return {'success':false,'message':_e(e),'data':e.response?.data}; }
    catch(e){ return _err(e.toString()); }
  }

  // ── DISCOUNT ELIGIBILITY ──────────────────────────────────────────────────
  Future<Map<String,dynamic>> applyForDiscount({required int accountId, required String userCategory, required String documentNumber}) async {
    try { final r = await _dio.post('/DiscountEligibility/ApplyForDiscount', data: {'accountId':accountId,'userCategory':userCategory,'documentNumber':documentNumber}); return _ok(r.data); }
    on DioException catch (e) { return {'success':false,'message':_e(e),'data':e.response?.data}; }
    catch(e){ return _err(e.toString()); }
  }

  Future<Map<String,dynamic>> getMyDiscount(int accountId) async {
    try { final r = await _dio.get('/DiscountEligibility/MyCategory/$accountId'); return _ok(r.data); }
    on DioException catch (e) {
      if (e.response?.statusCode == 404) return _ok(null);
      return _err(_e(e));
    }
    catch(e){ return _err(e.toString()); }
  }

  // ── ERROR ─────────────────────────────────────────────────────────────────
  String _e(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError: return 'لا يوجد اتصال بالإنترنت.';
      case DioExceptionType.receiveTimeout:  return 'استغرق الخادم وقتاً طويلاً.';
      case DioExceptionType.badResponse:
        final c = e.response?.statusCode;
        if (c == 400) return 'بيانات غير صحيحة.';
        if (c == 401) return 'غير مصرح. سجل الدخول مرة أخرى.';
        if (c == 404) return 'لم يتم العثور على البيانات.';
        if (c == 409) return 'البريد الإلكتروني مسجل مسبقاً.';
        if (c == 500) return 'خطأ في الخادم. حاول لاحقاً.';
        return 'خطأ: $c';
      default: return 'حدث خطأ. حاول مرة أخرى.';
    }
  }
}
