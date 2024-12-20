import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class UserController {

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

  static Future<void> addPledgedGift(String userId, String friendId, String eventId, String giftId) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId/pledgedGifts').push();
    await ref.set(
        {
          'friendId' : friendId,
          'eventId' : eventId,
          'giftId' : giftId
        }
    );
  }

  static Future<List<Map<String, String>>> getAllPledgedGifts(String userId) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId/pledgedGifts');
    final snapshot = await ref.get();

    if (snapshot.exists && snapshot.value is List) {
      return User.parsePledgedGifts(snapshot.value);
    } else if (snapshot.exists && snapshot.value is Map) {
      final data = (snapshot.value as Map<dynamic, dynamic>).values.toList();
      return User.parsePledgedGifts(data);
    }
    return [];
  }

  static Future<String?> getUserNameById(String userId) async {
    try {
      final ref = FirebaseDatabase.instance.ref('users/$userId');

      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data['name'] as String?;
      }
      return null;
    } catch (e) {
      print("Error fetching user name: $e");
      return null;
    }
  }

  static Future<void> removePledgedGift(String userId, String giftId) async {
    try {
      final ref = FirebaseDatabase.instance.ref('users/$userId/pledgedGifts');
      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value is List) {
        List<dynamic> pledgedGifts = snapshot.value as List;
        pledgedGifts.removeWhere((gift) => gift['giftId'] == giftId);
        await ref.set(pledgedGifts);
      } else if (snapshot.exists && snapshot.value is Map) {
        Map<dynamic, dynamic> pledgedGifts = snapshot.value as Map;
        pledgedGifts.removeWhere((key, value) => value['giftId'] == giftId);
        await ref.set(pledgedGifts);
      } else {
        print("No pledged gifts found.");
      }
    } catch (e) {
      print("Error removing pledged gift: $e");
    }
  }

  static Future<void> updateUserNotificationToken(String userId, String token) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId');
    await ref.update({
      'NotificationToken': token,
    });
  }

  static Future<String?> getNotificationToken(String userId) async {
    try {
      final ref = FirebaseDatabase.instance.ref('users/$userId/NotificationToken');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        return snapshot.value as String?;
      }
      return null;
    } catch (e) {
      print("Error fetching notification token: $e");
      return null;
    }
  }

  static Future<bool?> fetchNotificationPreferences(String userId) async {
    try {
      final ref = FirebaseDatabase.instance.ref('users/$userId/notificationPreferences');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        return snapshot.value as bool;
      } else {
        print("Notification preferences not found for user: $userId");
        return null;
      }
    } catch (e) {
      print("Error fetching notification preferences: $e");
      return null;
    }
  }

  static Future<User?> getUserByEmail(String email) async {
    try {
      final ref = FirebaseDatabase.instance.ref('users');
      final snapshot = await ref.get();
      if (snapshot.exists && snapshot.value is Map) {
        final users = Map<String, dynamic>.from(snapshot.value as Map);
        for (var entry in users.entries) {
          final userMap = Map<String, dynamic>.from(entry.value);
          if (userMap['email'] == email) {
            return User.fromFirebaseMap(userMap);
          }
        }
      }
      return null;
    } catch (e) {
      print("Error fetching user by email: $e");
      return null;
    }
  }

  static Future<bool> isNotificationEnabled(String userId) async {
    bool? isEnabled = await fetchNotificationPreferences(userId);
    return isEnabled ?? false;
  }
}
