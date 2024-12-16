import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/views/widget_tree.dart';
import '../models/user.dart';
import 'friend_events_page.dart';
import 'create_event_page.dart';
import 'create_gift_list_page.dart';
import 'common_widgets.dart';
import 'my_events_page.dart';
import 'profile_page.dart';
import 'package:hedieaty/services/auth.dart';

class HedieatyApp extends StatelessWidget{

  const HedieatyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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


class AppLayout extends StatelessWidget {
  const AppLayout({super.key});

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
                    backgroundImage: AssetImage(user.profilePicture),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: IconButton(
                    icon: Icon(Icons.person_add),
                    onPressed: () {
                      _addFriend(user, build_context);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<User>> _fetchAllUsers() async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
    final snapshot = await usersRef.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
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
      }).toList();
    } else {
      return [];
    }
  }


  void _addFriend(User friend, BuildContext context) async {
    final currentUser = Auth().currentUser?.uid;
    if (currentUser == null) return;

    DatabaseReference userFriendsRef = FirebaseDatabase.instance.ref('users/$currentUser/friends');
    await userFriendsRef.update({
      friend.id: true,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${friend.name} added as a friend!'),
      ),
    );
    print('${friend.name} added as a friend!');

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
        ? Center(child: CircularProgressIndicator())
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Card(
                  color: appColors['listCard'],
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: friend.profilePicture.isNotEmpty
                          ? AssetImage(friend.profilePicture)
                          : AssetImage('assets/images/default_profile.png')
                      as ImageProvider,
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
              );
            },
          ),
        ),
      ],
    );
  }
}
