import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import '../models/enums.dart';
import '../models/gift.dart';
import 'package:hedieaty/services/db_service.dart';

class GiftController {
  //SQLite
  static Future<void> saveDraft(Gift gift) async {
    final db = await DatabaseService().database;
    await db.insert('DraftGifts', gift.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Gift>> getDrafts() async {
    final db = await DatabaseService().database;
    final maps = await db.query('DraftGifts');
    return maps.map((map) => Gift.fromMap(map)).toList();
  }

  //Firebase
  static Future<void> publishToFirebase(Gift gift, String eventID, String userId) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId/events/$eventID/gifts').push();
    gift.id = ref.key ?? '';
    await ref.set(gift.toFirebaseMap());
  }

  static Future<List<Gift>> fetchFromFirebase(String eventID, String userId) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId/events/$eventID/gifts');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final Map<String, dynamic> giftsMap = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
      return Gift.parseGifts(giftsMap);
    }
    return [];
  }

  static Future<Gift?> getGiftById(String userId, String eventId, String giftId) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId/events/$eventId/gifts/$giftId');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final Map<String, dynamic> giftMap = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
      return Gift.fromFirebaseMap(giftMap);
    }
    return null;
  }


  static Future<void> updateStatus(String userId, String eventId, String giftId, GiftStatus newStatus, String pledgedBy) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId/events/$eventId/gifts/$giftId');
    await ref.update({
      'status': newStatus.name,
      'pledged_by' : pledgedBy
    });
  }

  static Future<void> updateInFirebase(String userId, String eventId, Gift gift) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId/events/$eventId/gifts/${gift.id}');
    await ref.update(gift.toFirebaseMap());
  }

  static Future<void> deleteFromFirebase(String userId, String eventId, String giftId) async {
    final ref = FirebaseDatabase.instance.ref('users/$userId/events/$eventId/gifts/$giftId');
    await ref.remove();
  }
}
