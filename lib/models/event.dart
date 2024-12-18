import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import '../services/db_service.dart';
import 'gift.dart';
import 'enums.dart';

class Event {
  String id;
  String name;
  DateTime date;
  String location;
  final String description;
  EventStatus status;
  final EventCategory category;
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
      'id': id,
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
      id: map['id'],
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

  //SQLite
  static Future<void> saveDraft(Event event) async {
    final db = await DatabaseService().database;
    await db.insert('DraftEvents', event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Event>> getDrafts() async {
    final db = await DatabaseService().database;
    final maps = await db.query('DraftEvents');
    return maps.map((map) => Event.fromMap(map)).toList();
  }

  //Firebase
  static Future<void> publishToFirebase(Event event, String userId) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId/events').push();
    event.id = ref.key ?? '';
    await ref.set(event.toFirebaseMap());
  }

  static Future<List<Event>> fetchFromFirebase(String userId) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId/events');
    final snapshot = await ref.get();

    if (snapshot.exists && snapshot.value is Map) {
      final eventsMap = snapshot.value as Map<dynamic, dynamic>;
      return eventsMap.values
          .map((e) => Event.fromFirebaseMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  static Future<void> deleteFromFirebase(String userId, String eventId) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId/events/$eventId');
    await ref.remove();
  }

  Future<void> updateInFirebase(String userId) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId/events/$id');
    await ref.update(toFirebaseMap());
  }

  static Future<DateTime?> getEventDateById(String userId, String eventId) async {
    try {
      final ref = FirebaseDatabase.instance.ref('users/$userId/events/$eventId');
      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        if (data['date'] != null) {
          return DateTime.parse(data['date']);
        }
      }
      return null;
    } catch (e) {
      print("Error fetching event date: $e");
      return null;
    }
  }
}