class TripDetails {
  final String trainName;
  final String tripType;
  final String from;
  final String to;
  final String date;
  final List<Station> stations;
  final List<TicketType> ticketTypes;

  TripDetails({
    required this.trainName,
    required this.tripType,
    required this.from,
    required this.to,
    required this.date,
    required this.stations,
    required this.ticketTypes,
  });
}

class Station {
  final String name;
  final String time;
  final bool isDeparture;

  Station({required this.name, required this.time, required this.isDeparture});
}

class TicketType {
  final String name;
  final String description;
  final String price;
  final String discount;

  TicketType({
    required this.name,
    required this.description,
    required this.price,
    this.discount = '',
  });
}
