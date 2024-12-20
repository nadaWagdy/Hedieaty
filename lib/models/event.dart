import 'gift.dart';
import 'enums.dart';

class Event {
  String id;
  String name;
  DateTime date;
  String location;
  String description;
  EventStatus status;
  EventCategory category;
  final List<Gift> eventGifts;

  Event({
    this.id = '',
    required this.name,
    required this.date,
    this.location = '',
    this.description = '',
    required this.status,
    required this.category,
    this.eventGifts = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'status': status.index,
      'category': category.index,
    };
  }

  static Event fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'].toString(),
      name: map['name'],
      date: DateTime.parse(map['date']),
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      status: EventStatus.values[map['status']],
      category: EventCategory.values[map['category']],
    );
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'status': status.name,
      'category': category.name,
    };
  }

  static Event fromFirebaseMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      status: EventStatus.values.firstWhere((e) => e.name == map['status']),
      category: EventCategory.values.firstWhere((e) => e.name == map['category']),
    );
  }
}