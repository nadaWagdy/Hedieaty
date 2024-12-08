import 'package:flutter/material.dart';
import 'package:hedieaty/views/widget_tree.dart';
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
            // functionality to add friends
            // might be a dialog
            // to be implemented
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

  // dummy data to be displayed for now
  List<Friend> friendsList = [
    Friend(name: 'Bob', profilePic: 'assets/images/profile1.jpg', upcomingEvents: 1, events: [
      Event(name: 'Birthday Party', status: 'Upcoming', category: 'Birthday'),
    ]),
    Friend(name: 'Alice', profilePic: 'assets/images/profile2.jpg', upcomingEvents: 0, events: []),
    Friend(name: 'Kiara', profilePic: 'assets/images/profile3.jpg', upcomingEvents: 3, events: [
      Event(name: 'Birthday Party', status: 'Upcoming', category: 'Birthday'),
      Event(name: 'Graduation', status: 'Upcoming', category: 'Personal'),
      Event(name: 'Wedding', status: 'Upcoming', category: 'Wedding'),
    ]),
    Friend(name: 'Marc', profilePic: 'assets/images/profile4.jpg', upcomingEvents: 2, events: [
      Event(name: 'Birthday Party', status: 'Upcoming', category: 'Birthday'),
      Event(name: 'Wedding', status: 'Upcoming', category: 'Wedding'),
    ],),
    Friend(name: 'Bob', profilePic: 'assets/images/profile1.jpg', upcomingEvents: 1, events: [
      Event(name: 'Birthday Party', status: 'Upcoming', category: 'Birthday'),
    ]),
    Friend(name: 'Alice', profilePic: 'assets/images/profile2.jpg', upcomingEvents: 0, events: []),
    Friend(name: 'Kiara', profilePic: 'assets/images/profile3.jpg', upcomingEvents: 3, events: [
      Event(name: 'Birthday Party', status: 'Upcoming', category: 'Birthday'),
      Event(name: 'Graduation', status: 'Upcoming', category: 'Personal'),
      Event(name: 'Wedding', status: 'Upcoming', category: 'Wedding'),
    ]),
    Friend(name: 'Marc', profilePic: 'assets/images/profile4.jpg', upcomingEvents: 2, events: [
      Event(name: 'Birthday Party', status: 'Upcoming', category: 'Birthday'),
      Event(name: 'Wedding', status: 'Upcoming', category: 'Wedding'),
    ],),
    Friend(name: 'Bob', profilePic: 'assets/images/profile1.jpg', upcomingEvents: 1, events: [
      Event(name: 'Birthday Party', status: 'Upcoming', category: 'Birthday'),
    ]),
    Friend(name: 'Alice', profilePic: 'assets/images/profile2.jpg', upcomingEvents: 0, events: []),
    Friend(name: 'Kiara', profilePic: 'assets/images/profile3.jpg', upcomingEvents: 3, events: [
      Event(name: 'Birthday Party', status: 'Upcoming', category: 'Birthday'),
      Event(name: 'Graduation', status: 'Upcoming', category: 'Personal'),
      Event(name: 'Wedding', status: 'Upcoming', category: 'Wedding'),
    ]),
    Friend(name: 'Marc', profilePic: 'assets/images/profile4.jpg', upcomingEvents: 2, events: [
      Event(name: 'Birthday Party', status: 'Upcoming', category: 'Birthday'),
      Event(name: 'Wedding', status: 'Upcoming', category: 'Wedding'),
    ],),
  ];


  String searchQuery = '';

  List<Friend> get filteredFriendsList {
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
    return Column(
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
          child: ListView.builder(
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
                      radius: 30,
                      backgroundImage: AssetImage(friend.profilePic),
                    ),
                    title: Text(
                      friend.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: appColors['background'],
                      ),
                    ),
                    subtitle: Text(
                      friend.upcomingEvents > 0
                          ? 'Upcoming Events: ${friend.upcomingEvents}'
                          : 'No Upcoming Events',
                      style: TextStyle(
                          color: friend.upcomingEvents > 0
                              ? appColors['primary']
                              : appColors['unselected'],
                          fontSize: 16
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventListPage(friend: friend),
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