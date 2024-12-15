import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import '../services/db_service.dart';
import 'event.dart';
import 'gift.dart';

class User {
  final String id;
  String name;
  final String email;
  bool notificationPreferences;
  String profilePicture;
  final List<Event> events;
  final List<String> friends;
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
      'friends': {for (var friendId in friends) friendId: true},
    };
  }

  static User fromFirebaseMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      notificationPreferences: map['notificationPreferences'],
      profilePicture: map['profilePicture'] ?? '',
      events: parseEvents(map['events']),
      pledgedGifts: parseGifts(map['pledgedGifts']),
      friends: parseFriendIds(map['friends']),
    );
  }

  static List<Event> parseEvents(dynamic data) {
    if (data is Map) {
      return data.entries.map((entry) {
        return Event.fromFirebaseMap(Map<String, dynamic>.from(entry.value));
      }).toList();
    }
    return [];
  }

  static List<Gift> parseGifts(dynamic data) {
    if (data is Map) {
      return data.entries.map((entry) {
        return Gift.fromFirebaseMap(Map<String, dynamic>.from(entry.value));
      }).toList();
    }
    return [];
  }

  static List<String> parseFriendIds(dynamic data) {
    if (data is Map) {
      return data.keys.map((key) => key.toString()).toList();
    }
    return [];
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    bool? notificationPreferences,
    List<Event>? events,
    List<String>? friends,
    List<Gift>? pledgedGifts,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      events: events ?? this.events,
      friends: friends ?? this.friends,
      pledgedGifts: pledgedGifts ?? this.pledgedGifts,
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

    if (snapshot.exists && snapshot.value is Map) {
      return User.fromFirebaseMap(Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }

  static Future<void> updateNotificationPreferences(String userId, bool newPreference) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId');
    await ref.update({
      'notificationPreferences': newPreference,
    });
  }

  static Future<void> updateUserName(String userId, String newName) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId');
    await ref.update({
      'name': newName,
    });
  }

  static Future<void> updateProfilePicture(String userId, String newPath) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId');
    await ref.update({
      'profilePicture': newPath,
    });
  }

}