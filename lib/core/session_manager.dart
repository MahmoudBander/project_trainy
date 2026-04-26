import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyToken       = 'token';
  static const _keyAccountId   = 'accountId';
  static const _keyName        = 'name';
  static const _keyRole        = 'role';
  static const _keyEmail       = 'email';
  static const _keyPhone       = 'phone';
  static const _keyFromStation = 'fromStation';
  static const _keyToStation   = 'toStation';
  static const _keyDeparture   = 'departure';
  static const _keyArrival     = 'arrival';
  static const _keyTrainName   = 'trainName';
  static const _keyTripDate    = 'tripDate';
  static const _keySeatNumber  = 'seatNumber';
  static const _keyTicketPrice = 'ticketPrice';

  static Future<void> save({required String token, required dynamic accountId, required String name, required String role, String email = '', String phone = ''}) async {
    final p = await SharedPreferences.getInstance();
    final int id = accountId is int ? accountId : int.tryParse(accountId?.toString() ?? '0') ?? 0;
    await p.setString(_keyToken, token);
    await p.setInt(_keyAccountId, id);
    await p.setString(_keyName, name);
    await p.setString(_keyRole, role);
    await p.setString(_keyEmail, email);
    await p.setString(_keyPhone, phone);
  }

  static Future<void> saveTripData({required String fromStation, required String toStation, required String departure, required String arrival, required String trainName, required String tripDate, String seatNumber = '', double ticketPrice = 0}) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyFromStation, fromStation);
    await p.setString(_keyToStation, toStation);
    await p.setString(_keyDeparture, departure);
    await p.setString(_keyArrival, arrival);
    await p.setString(_keyTrainName, trainName);
    await p.setString(_keyTripDate, tripDate);
    await p.setString(_keySeatNumber, seatNumber);
    if (ticketPrice > 0) await p.setDouble(_keyTicketPrice, ticketPrice);
  }

  static Future<String?> getToken()       async => (await SharedPreferences.getInstance()).getString(_keyToken);
  static Future<int?>    getAccountId()   async => (await SharedPreferences.getInstance()).getInt(_keyAccountId);
  static Future<String?> getName()        async => (await SharedPreferences.getInstance()).getString(_keyName);
  static Future<String?> getRole()        async => (await SharedPreferences.getInstance()).getString(_keyRole);
  static Future<String?> getEmail()       async => (await SharedPreferences.getInstance()).getString(_keyEmail);
  static Future<String?> getPhone()       async => (await SharedPreferences.getInstance()).getString(_keyPhone);
  static Future<String?> getFromStation() async => (await SharedPreferences.getInstance()).getString(_keyFromStation);
  static Future<String?> getToStation()   async => (await SharedPreferences.getInstance()).getString(_keyToStation);
  static Future<String?> getDeparture()   async => (await SharedPreferences.getInstance()).getString(_keyDeparture);
  static Future<String?> getArrival()     async => (await SharedPreferences.getInstance()).getString(_keyArrival);
  static Future<String?> getTrainName()   async => (await SharedPreferences.getInstance()).getString(_keyTrainName);
  static Future<String?> getTripDate()    async => (await SharedPreferences.getInstance()).getString(_keyTripDate);
  static Future<String?> getSeatNumber()  async => (await SharedPreferences.getInstance()).getString(_keySeatNumber);
  static Future<double?> getTicketPrice() async => (await SharedPreferences.getInstance()).getDouble(_keyTicketPrice);

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_keyToken);
    await p.remove(_keyAccountId);
    await p.remove(_keyName);
    await p.remove(_keyRole);
    await p.remove(_keyEmail);
    await p.remove(_keyPhone);
  }
}