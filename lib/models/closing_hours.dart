import 'package:cloud_firestore/cloud_firestore.dart';

class ClosingHours {
  List<ClosingHour> closingHours;

  ClosingHours({
    this.closingHours,
  });

  factory ClosingHours.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return ClosingHours(
      closingHours: getListOfClosingHours(data['closingHours']),
    );
  }
}

class ClosingHour {
  String day;
  DinnerClosingHour dinner;
  LunchClosingHour lunch;
  String id;

  ClosingHour({
    this.day,
    this.dinner,
    this.lunch,
    this.id,
  });

  factory ClosingHour.fromHashmap(Map<String, dynamic> map) {
    return ClosingHour(
      day: map['day'],
      id: map['id'],
      dinner: DinnerClosingHour.fromHashmap(map['dinner']),
      lunch: LunchClosingHour.fromHashmap(map['lunch']),
    );
  }
}

class DinnerClosingHour {
  Timestamp from;
  Timestamp to;

  DinnerClosingHour({
    this.from,
    this.to,
  });

  factory DinnerClosingHour.fromHashmap(Map<String, dynamic> map) {
    return DinnerClosingHour(
      from: map['from'],
      to: map['to'],
    );
  }
}

class LunchClosingHour {
  Timestamp from;
  Timestamp to;

  LunchClosingHour({
    this.from,
    this.to,
  });

  factory LunchClosingHour.fromHashmap(Map<String, dynamic> map) {
    return LunchClosingHour(
      from: map['from'],
      to: map['to'],
    );
  }
}

List<ClosingHour> getListOfClosingHours(Map extras) {
  List<ClosingHour> list = List();
  extras.forEach((key, value) {
    list.add(ClosingHour.fromHashmap(value));
  });

  return list;
}
