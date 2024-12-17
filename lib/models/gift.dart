import 'package:firebase_database/firebase_database.dart';
import 'package:hedieaty/models/enums.dart';
import 'package:sqflite/sqflite.dart';
import '../services/db_service.dart';

class Gift {
  String id;
  final String name;
  final String? description;
  final GiftCategory? category;
  final double? price;
  GiftStatus status;
  final String eventID;
  String? pledgedBy;

  Gift({
    this.id = '',
    required this.name,
    this.description,
    this.category,
    this.price,
    required this.status,
    required this.eventID,
    this.pledgedBy
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category?.index,
      'price': price,
      'status': status.index,
      'event_id': eventID,
    };
  }

  static Gift fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'] != null
          ? GiftCategory.values[map['category']]
          : null,
      price: map['price'],
      status: GiftStatus.values[map['status']],
      eventID: map['event_id'],
    );
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category?.name,
      'price': price,
      'status': status.name,
      'event_id': eventID,
      'pledged_by': pledgedBy
    };
  }

  static Gift fromFirebaseMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'] != null
          ? GiftCategory.values.firstWhere(
              (e) => e.name == map['category'], orElse: () => GiftCategory.other)
          : null,
      price: map['price'] != null ? double.tryParse(map['price'].toString()) : null,
      status: GiftStatus.values.firstWhere(
              (e) => e.name == map['status'], orElse: () => GiftStatus.available),
      eventID: map['event_id'] ?? '',
      pledgedBy: map['pledged_by']
    );
  }

  static List<Gift> parseGifts(dynamic data) {
    if (data is Map) {
      return data.entries.map((entry) {
        return Gift.fromFirebaseMap(Map<String, dynamic>.from(entry.value));
      }).toList();
    }
    return [];
  }


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
      return parseGifts(giftsMap);
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

}