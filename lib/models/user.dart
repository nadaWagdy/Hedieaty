import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import '../services/db_service.dart';
import 'event.dart';
import 'gift.dart';

class User {
  final String id;
  final String name;
  final String email;
  final bool notificationPreferences;
  final String profilePicture;
  final List<Event> events;
  final List<User> friends;
  final List<Gift> pledgedGifts;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.notificationPreferences,
    required this.profilePicture,
    this.events = const [],
    this.friends = const [],
    this.pledgedGifts = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'notification_preferences': notificationPreferences ? 1 : 0,
      'profile_picture': profilePicture,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      notificationPreferences: map['notification_preferences'] == 1,
      profilePicture: map['profile_picture'],
    );
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'notificationPreferences': notificationPreferences,
      'profilePicture': profilePicture,
      'events': events.map((e) => e.toFirebaseMap()).toList(),
      'pledgedGifts': pledgedGifts.map((g) => g.toFirebaseMap()).toList(),
      'friends': friends.map((f) => f.toFirebaseMap()).toList(),
    };
  }

  static User fromFirebaseMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      notificationPreferences: map['notificationPreferences'],
      profilePicture: map['profilePicture'] ?? '',
      events: (map['events'] as List<dynamic>)
          .map((e) => Event.fromFirebaseMap(e as Map<String, dynamic>))
          .toList(),
      pledgedGifts: (map['pledgedGifts'] as List<dynamic>)
          .map((g) => Gift.fromFirebaseMap(g as Map<String, dynamic>))
          .toList(),
      friends: (map['friends'] as List<dynamic>)
          .map((f) => User.fromFirebaseMap(f as Map<String, dynamic>))
          .toList(),
    );
  }

  //SQLite
  static Future<void> saveDraft(User user) async {
    final db = await DatabaseService().database;
    await db.insert('DraftUsers', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<User>> getDrafts() async {
    final db = await DatabaseService().database;
    final maps = await db.query('DraftUsers');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  //Firebase
  static Future<void> publishToFirebase(User user) async {
    final ref = FirebaseDatabase.instance.ref('users/${user.id}');
    await ref.set(user.toFirebaseMap());
  }

  static Future<User?> fetchFromFirebase(String userId) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return User.fromMap(snapshot.value as Map<String, dynamic>);
    }
    return null;
  }
}