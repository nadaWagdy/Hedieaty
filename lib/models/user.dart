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
  final List<Map<String, String>> pledgedGifts;

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
      'pledgedGifts': pledgedGifts.map((pg) => {
        'friendId': pg['friendId'],
        'eventId': pg['eventId'],
        'giftId': pg['giftId'],
      }).toList(),
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
      pledgedGifts: parsePledgedGifts(map['pledgedGifts']),
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

  static List<Map<String, String>> parsePledgedGifts(dynamic data) {
    if (data is List) {
      return data
          .map((item) => Map<String, String>.from(item as Map<dynamic, dynamic>))
          .toList();
    }
    return [];
  }

}