import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'common_widgets.dart';
import 'friend_gift_lists_page.dart';
import 'package:hedieaty/models/event.dart' as event_model;
import 'package:hedieaty/models/user.dart';

class EventListPage extends StatefulWidget {
  final String friendId;

  const EventListPage({Key? key, required this.friendId}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<event_model.Event> friendEvents = [];
  bool isLoading = true;
  User? _friend;

  static const IconData giftIcon = IconData(0xf689, fontFamily: 'lxgw', );

  @override
  void initState() {
    super.initState();
    fetchEvents(widget.friendId);
    _fetchFriendData(widget.friendId);
  }

  Future<void> fetchEvents(String id) async {
    try {
      final fetchedEvents = await event_model.Event.fetchFromFirebase(id);
      setState(() {
        friendEvents = fetchedEvents;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchFriendData(String id) async {

    try {
      User? user = await User.fetchFromFirebase(id);

      if (user != null) {
        setState(() {
          _friend = user;
          isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching friend data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isLoading ? createSubPageAppBar(''): createSubPageAppBar('${_friend!.name}\'s Events'),
      body: isLoading ? Center(child: CircularProgressIndicator(color: appColors['primary'],)) :
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: getImageProvider(_friend!.profilePicture),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _friend!.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: appColors['buttonText'],
                        ),
                      ),
                      Text(
                        _friend!.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: appColors['buttonText'],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Expanded(
              child: ListView.builder(
                itemCount: friendEvents.length,
                itemBuilder: (context, index) {
                  final event = friendEvents[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Card(
                      color: appColors['listCard'],
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(event.name,
                          style: TextStyle(
                              color: appColors['primary'],
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                  text: 'Category: ',
                                  style: TextStyle(fontSize: 18, color: appColors['primary'], fontWeight: FontWeight.bold, fontFamily: 'lxgw'),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '${event.category.name}',
                                      style: TextStyle(fontSize: 18, color: appColors['background'], fontWeight: FontWeight.normal),
                                    )
                                  ]
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                  text: 'Status: ',
                                  style: TextStyle(fontSize: 18, color: appColors['primary'], fontWeight: FontWeight.bold, fontFamily: 'lxgw'),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '${event.status.name}',
                                      style: TextStyle(fontSize: 18, color: appColors['background'], fontWeight: FontWeight.normal),
                                    )
                                  ]
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                  text: 'Date: ',
                                  style: TextStyle(fontSize: 18, color: appColors['primary'], fontWeight: FontWeight.bold, fontFamily: 'lxgw'),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '${event.date.toLocal().toString().split(' ')[0]}',
                                      style: TextStyle(fontSize: 18, color: appColors['background'], fontWeight: FontWeight.normal),
                                    )
                                  ]
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                  text: 'Location: ',
                                  style: TextStyle(fontSize: 18, color: appColors['primary'], fontWeight: FontWeight.bold, fontFamily: 'lxgw'),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '${event.location}',
                                      style: TextStyle(fontSize: 18, color: appColors['background'], fontWeight: FontWeight.normal),
                                    )
                                  ]
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(CupertinoIcons.gift_fill,
                            color: appColors['primary'],
                            size: 40,
                          ),
                          onPressed: () {

                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FriendsGiftListPage(friendId: _friend!.id, eventId: event.id, friendName: _friend!.name, eventName: event.name,),
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
        ),
      ),
    );
  }
}