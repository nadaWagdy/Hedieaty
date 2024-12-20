import 'package:hedieaty/models/enums.dart';


class Gift {
  String id;
  String name;
  String? description;
  GiftCategory? category;
  double? price;
  GiftStatus status;
  final String eventID;
  String? pledgedBy;
  String? imagePath;

  Gift({
    this.id = '',
    required this.name,
    this.description,
    this.category,
    this.price,
    required this.status,
    required this.eventID,
    this.pledgedBy,
    this.imagePath
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category?.index,
      'price': price,
      'status': status.index,
      'event_id': eventID,
      'imagePath' : imagePath
    };
  }

  static Gift fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'].toString(),
      name: map['name'],
      description: map['description'],
      category: map['category'] != null
          ? GiftCategory.values[map['category']]
          : null,
      price: map['price'],
      status: GiftStatus.values[map['status']],
      eventID: map['event_id'],
      imagePath: map['imagePath']
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
      'pledged_by': pledgedBy,
      'imagePath': imagePath
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
      pledgedBy: map['pledged_by'],
      imagePath: map['imagePath']
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

}