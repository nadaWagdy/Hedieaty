import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/views/widget_tree.dart';
import '../controllers/user_controller.dart';
import '../models/user.dart';
import '../services/notification_service.dart';
import 'friend_events_page.dart';
import 'create_event_page.dart';
import 'create_gift_list_page.dart';
import 'common_widgets.dart';
import 'my_events_page.dart';
import 'profile_page.dart';
import 'package:hedieaty/services/auth.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class HedieatyApp extends StatelessWidget{

  const HedieatyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Hedieaty',
      home: WidgetTree(),
      theme: ThemeData(
          scaffoldBackgroundColor: appColors['background']
      ),
      routes: {
        "/Home": (context) => const HomePage(),
        "/myEvents": (context) => MyEventsPage(),
        "/createEvents": (context) => CreateEventPage(),
        "/createGiftList": (context) => CreateGiftListPage(),
        "/profile": (context) => ProfilePage(),
      },
    );
  }

}

class AppLayout extends StatefulWidget {

  const AppLayout({super.key});

  @override
  _AppLayoutState createState() => _AppLayoutState();
}


class _AppLayoutState extends State<AppLayout> {

  Future<void> signOut() async {
    await Auth().signOut();
  }

  void _showAddFriendDialog(BuildContext build_context) async {
    final currentUser = Auth().currentUser?.uid;
    List<User> allUsers = await _fetchAllUsers();
    List<User> filteredUsers = allUsers.where((user) => user.id != currentUser).toList();

    showDialog(
      context: build_context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Friend'),
          content: filteredUsers.isEmpty
              ? Text('No other users found.')
              : SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: getImageProvider(user.profilePicture),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: IconButton(
                    icon: Icon(Icons.person_add),
                    onPressed: () {
                      _addFriend(user);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Add Manually', style: TextStyle(color: appColors['primary'], fontSize: 18),),
              onPressed: () async {
                Navigator.pop(context);
                String? friendEmail = await _showAddFriendManuallyDialog(build_context);
                if (friendEmail != null && friendEmail.isNotEmpty) {
                  _addFriendManually(friendEmail);
                } else {
                  scaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(
                      content: Text('Email Field Was Empty'),
                    ),
                  );
                }
              },
            ),
            TextButton(
              child: Text('Cencel', style: TextStyle(color: appColors['primary'], fontSize: 18),),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addFriendManually(String email) async {
    final userId = Auth().currentUser?.uid;
    final newFriend = await UserController.getUserByEmail(email);
    if(newFriend != null){
      if (newFriend.id == userId) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('This is your email'),
          ),
        );
        return;
      }
      _addFriend(newFriend);
    } else {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('No User With This Email Was Found. Try Another Email'),
        ),
      );
    }
  }

  Future<String?> _showAddFriendManuallyDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Friend By Email',
            style: TextStyle(
                color: appColors['primary'],
                fontFamily: 'lxgw',
                fontWeight: FontWeight.bold,
                fontSize: 24),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Enter Friend Email',
              labelStyle: TextStyle(
                color: appColors['primary'],
                fontWeight: FontWeight.bold,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: Color(0xFFF41F4E),
                  width: 2.0,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: Text('Add', style: TextStyle(fontSize: 18),),
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors['primary'],
                foregroundColor: appColors['buttonText'],
                shadowColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding:
                EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel',  style: TextStyle(color: appColors['primary'], fontSize: 18)),
            ),
          ],
        );
      },
    );
  }

  Future<List<User>> _fetchAllUsers() async {
    final currentUserId = Auth().currentUser?.uid;
    DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
    final snapshot = await usersRef.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final currentUserSnapshot = await usersRef.child(currentUserId!).get();

      if (currentUserSnapshot.exists) {
        final currentUserData = currentUserSnapshot.value as Map<dynamic, dynamic>;
        final currentFriends = User.parseFriendIds(currentUserData['friends']);

        return data.entries
            .where((entry) => entry.key != currentUserId && !currentFriends.contains(entry.key))
            .map((entry) {
          final userId = entry.key;
          final userData = entry.value;
          return User(
            id: userId,
            name: userData['name'] ?? 'No Name',
            email: userData['email'] ?? '',
            profilePicture: userData['profilePicture'] ?? '',
            notificationPreferences: userData['notificationPreferences'] ?? true,
            events: User.parseEvents(userData['events']),
            friends: User.parseFriendIds(userData['friends']),
            pledgedGifts: User.parsePledgedGifts(userData['pledgedGifts']),
          );
        })
            .toList();
      }
    }

    return [];
  }



  void _addFriend(User friend) async {
    final currentUser = Auth().currentUser?.uid;
    if (currentUser == null) return;

    DatabaseReference userFriendsRef = FirebaseDatabase.instance.ref('users/$currentUser/friends');
    await userFriendsRef.update({
      friend.id: true,
    });

    DatabaseReference friendUserRef = FirebaseDatabase.instance.ref('users/${friend.id}/friends');
    await friendUserRef.update({
      currentUser: true,
    });

    sendAddedFriendNotification(friend.id);
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('${friend.name} added as a friend!'),
      ),
    );
    setState(() {
    });
    print('${friend.name} added as a friend!');
  }

  Future<void> sendAddedFriendNotification(String friendID) async {
    try {
      bool isEnabled = await UserController.isNotificationEnabled(friendID);
      if(!isEnabled){
        return;
      }
      final friendToken = await UserController.getNotificationToken(friendID);
      final userId = Auth().currentUser?.uid;
      final userName = await UserController.getUserNameById(userId!);
      if (friendToken != null) {
        await NotificationService().sendNotification(
          token: friendToken,
          title: 'You Have A New Friend!',
          body: '$userName added you as a friend',
        );
      } else {
        print('Friend\'s FCM token not found.');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Hedieaty",
            style: TextStyle(
              fontFamily: 'lxgw',
              color: Colors.white,
              fontSize: 40,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.person,
                size: 50,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            IconButton(
              icon: Icon(Icons.logout,
                size: 50,
                color: Colors.white,
              ),
              onPressed: () {
                signOut();
              },
            ),
          ],
          toolbarHeight: 90,
          elevation: 0,
          backgroundColor: appColors['background'],
        ),
        body: HomePage(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddFriendDialog(context);
          },
          child: Icon(Icons.person_add,
            color: appColors['buttonText'],
          ),
          backgroundColor: appColors['primary'],
        ),
    );
  }
}



class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<User> friendsList = [];
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
    _addFriendsListener();
  }

  Future<void> _fetchFriends() async {
    final currentUser = Auth().currentUser?.uid;
    if (currentUser == null) return;

    try {
      DatabaseReference userFriendsRef = FirebaseDatabase.instance.ref('users/$currentUser/friends');
      final friendsSnapshot = await userFriendsRef.get();

      if (friendsSnapshot.exists) {
        final friendsIds = (friendsSnapshot.value as Map<dynamic, dynamic>).keys;

        DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
        List<User> loadedFriends = [];
        for (var friendId in friendsIds) {
          final friendSnapshot = await usersRef.child(friendId).get();
          if (friendSnapshot.exists) {
            final friendData = friendSnapshot.value as Map<dynamic, dynamic>;
            loadedFriends.add(User(
              id: friendId,
              name: friendData['name'] ?? 'No Name',
              email: friendData['email'] ?? '',
              profilePicture: friendData['profilePicture'] ?? '',
              notificationPreferences: friendData['notificationPreferences'] ?? true,
              events: User.parseEvents(friendData['events']),
              friends: User.parseFriendIds(friendData['friends']),
              pledgedGifts: User.parsePledgedGifts(friendData['pledgedGifts']),
            ));
          }
        }

        setState(() {
          friendsList = loadedFriends;
          isLoading = false;
        });
      } else {
        setState(() {
          friendsList = [];
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching friends: $error');
      setState(() {
        friendsList = [];
        isLoading = false;
      });
    }
  }

  StreamSubscription<DatabaseEvent>? friendsStream;

  void _addFriendsListener() {
    final currentUser = Auth().currentUser?.uid;
    if (currentUser == null) return;

    DatabaseReference userFriendsRef = FirebaseDatabase.instance.ref('users/$currentUser/friends');
    friendsStream = userFriendsRef.onValue.listen((event) async {
      if (event.snapshot.exists) {
        final friendsIds = (event.snapshot.value as Map<dynamic, dynamic>).keys;

        DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
        List<User> updatedFriendsList = [];
        for (var friendId in friendsIds) {
          final friendSnapshot = await usersRef.child(friendId).get();
          if (friendSnapshot.exists) {
            final friendData = friendSnapshot.value as Map<dynamic, dynamic>;
            updatedFriendsList.add(User(
              id: friendId,
              name: friendData['name'] ?? 'No Name',
              email: friendData['email'] ?? '',
              profilePicture: friendData['profilePicture'] ?? '',
              notificationPreferences: friendData['notificationPreferences'] ?? true,
              events: User.parseEvents(friendData['events']),
              friends: User.parseFriendIds(friendData['friends']),
              pledgedGifts: User.parsePledgedGifts(friendData['pledgedGifts']),
            ));
          }
        }

        setState(() {
          friendsList = updatedFriendsList;
        });
      } else {
        setState(() {
          friendsList = [];
        });
      }
    });
  }

  void _deleteFriend(User friend) async {
    final currentUser = Auth().currentUser?.uid;
    if (currentUser == null) return;

    DatabaseReference userFriendsRef = FirebaseDatabase.instance.ref('users/$currentUser/friends/${friend.id}');
    await userFriendsRef.remove();

    DatabaseReference friendUserRef = FirebaseDatabase.instance.ref('users/${friend.id}/friends/$currentUser');
    await friendUserRef.remove();

    sendDeletedFriendNotification(friend.id);
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('${friend.name} removed from friends list!'),
      ),
    );

    setState(() {});

    print('${friend.name} removed from friends list!');
  }

  Future<void> sendDeletedFriendNotification(String friendID) async {
    try {
      bool isEnabled = await UserController.isNotificationEnabled(friendID);
      if(!isEnabled){
        return;
      }
      final friendToken = await UserController.getNotificationToken(friendID);
      final userId = Auth().currentUser?.uid;
      final userName = await UserController.getUserNameById(userId!);
      if (friendToken != null) {
        await NotificationService().sendNotification(
          token: friendToken,
          title: 'Your Friend Removed You!',
          body: '$userName removed you from their friends list',
        );
      } else {
        print('Friend\'s FCM token not found.');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  List<User> get filteredFriendsList {
    if (searchQuery.isEmpty) {
      return friendsList;
    } else {
      return friendsList
          .where((friend) =>
          friend.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Event or Gift List',
            style: TextStyle(
                color: appColors['primary'],
                fontWeight: FontWeight.bold,
                fontFamily: 'lxgw',
                fontSize: 22
            ),
          ),
          content: Text('Would you like to create an event or a gift list?',
            style: TextStyle(
                fontSize: 18
            ),

          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventPage(),
                  ),
                );
              },
              child: Text('Create Event',
                style: TextStyle(
                    color: appColors['primary'],
                    fontSize: 16,
                    fontFamily: 'lxgw',
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateGiftListPage(),
                  ),
                );
              },
              child: Text('Create Gift List',
                style: TextStyle(
                    color: appColors['primary'],
                    fontSize: 16,
                    fontFamily: 'lxgw',
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator(color: appColors['primary'],))
        : Column(
      children: [
        SizedBox(
          height: 35,
        ),
        ElevatedButton(
          onPressed: () {
            _showCreateDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: appColors['primary'],
            foregroundColor: appColors['buttonText'],
            elevation: 8,
            shadowColor: Colors.blueGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Text('Create Your Own Event/List'),
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            style: TextStyle(
                color: appColors['buttonText']
            ),
            cursorColor: appColors['buttonText'],
            decoration: SearchFieldDecoration.searchInputDecoration('Search friends...'),
          ),
        ),
        Expanded(
          child: filteredFriendsList.isEmpty
              ? Center(
            child: Text(
              'No friends found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          )
              : ListView.builder(
            itemCount: filteredFriendsList.length,
            itemBuilder: (context, index) {
              final friend = filteredFriendsList[index];
              return Dismissible(
                key: Key(filteredFriendsList[index].id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _deleteFriend(friend);
                },
                confirmDismiss: (direction) async {
                  final bool? confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Deletion'),
                        content: Text('Are you sure you want to delete this item?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel', style: TextStyle(color: appColors['primary']),),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColors['primary'],
                              foregroundColor: appColors['buttonText'],
                              shadowColor: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding:
                              EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  return confirm ?? false;
                },
                background: Container(
                  color: appColors['primary'],
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    color: appColors['listCard'],
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: getImageProvider(friend.profilePicture),
                      ),
                      title: Text(friend.name),
                      subtitle: Text(friend.email),
                      trailing: friend.events.isNotEmpty
                          ? Text(
                        "Upcoming Events: ${friend.events.length}",
                        style: TextStyle(color: Colors.green, fontSize: 14, fontFamily: 'lxgw', fontWeight: FontWeight.bold),
                      )
                          : Text(
                        "No Upcoming Events",
                        style: TextStyle(color: Colors.red, fontSize: 14, fontFamily: 'lxgw', fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventListPage(friendId: friend.id,),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    friendsStream?.cancel();
    super.dispose();
  }
}
