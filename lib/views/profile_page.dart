import 'package:flutter/material.dart';
import 'package:hedieaty/views/common_widgets.dart';
import 'my_pledged_gifts_page.dart';
import 'my_event_gift_lists_page.dart';
import 'my_events_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String userName = "Maria";
  final String email = "Maria@example.com";
  final String profileImageUrl =
      "https://images.unsplash.com/photo-1502323777036-f29e3972d82f?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
  final List<Map<String, dynamic>> createdEvents = [
    {
      "eventName": "Birthday Party",
      "gifts": ["Smartwatch", "Gift Card"],
    },
    {
      "eventName": "Wedding Anniversary",
      "gifts": ["Wireless Headphones"],
    },
    {
      "eventName": "Birthday Party",
      "gifts": ["Smartwatch", "Gift Card"],
    },
    {
      "eventName": "Wedding Anniversary",
      "gifts": ["Wireless Headphones"],
    },
    {
      "eventName": "Birthday Party",
      "gifts": ["Smartwatch", "Gift Card"],
    },
    {
      "eventName": "Wedding Anniversary",
      "gifts": ["Wireless Headphones"],
    },
    {
      "eventName": "Birthday Party",
      "gifts": ["Smartwatch", "Gift Card"],
    },
    {
      "eventName": "Wedding Anniversary",
      "gifts": ["Wireless Headphones"],
    },
  ];

  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createSubPageAppBar('Profile'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profileImageUrl),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: appColors['buttonText']
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(fontSize: 16,
                          color: appColors['buttonText']
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit,
                  color: appColors['buttonText'],
                  ),
                  onPressed: () {

                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text("Enable Notifications",
                style: TextStyle(
                  color: appColors['buttonText'],
                  fontSize: 20
                ),
              ),
              activeColor: appColors['primary'],
              inactiveThumbColor: appColors['buttonText'],
              inactiveTrackColor: appColors['unselected'],
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            Divider(thickness: 2),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Created Events",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: appColors['buttonText']
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyEventsPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors['primary'],
                    foregroundColor: appColors['buttonText'],
                    shadowColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text('Show all events',
                    style: TextStyle(
                      fontSize: 16
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 20,),
            Expanded(
              child: ListView.builder(
                itemCount: createdEvents.length,
                itemBuilder: (context, index) {
                  final event = createdEvents[index];
                  return Card(
                    color: appColors['listCard'],
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(event["eventName"],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      subtitle: Text(
                        "Gifts: ${event["gifts"].join(", ")}",
                        style: TextStyle(
                            fontSize: 18,
                          color: appColors['primary']
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyEventGiftsListPage(
                              eventName: event["eventName"],
                              gifts: List<String>.from(event["gifts"]),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20,),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPledgedGiftsPage(),
                  ),
                );
              },
              child: Text(
                "View My Pledged Gifts",
                style: TextStyle(
                  color: appColors['primary'],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
