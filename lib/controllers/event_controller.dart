import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import '../models/event.dart';
import '../services/db_service.dart';

class EventController {

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

  static Future<void> updateInFirebase(String userId, Event event) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId/events/${event.id}');
    await ref.update(event.toFirebaseMap());
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
