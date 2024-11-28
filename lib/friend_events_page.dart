import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'common_widgets.dart';
import 'friend_gift_lists_page.dart';

class EventListPage extends StatefulWidget {
  final Friend friend;

  const EventListPage({Key? key, required this.friend}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  late List<Event> friendEvents;

  static const IconData giftIcon = IconData(0xf689, fontFamily: 'lxgw', );

  @override
  void initState() {
    super.initState();
    friendEvents = widget.friend.events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createSubPageAppBar('${widget.friend.name}\'s Events'),
      body: Column(
        children: [
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
                          fontSize: 20
                        ),
                      ),
                      subtitle: Text(event.status,
                        style: TextStyle(
                          fontSize: 16
                        ),
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
                            builder: (context) => FriendsGiftListPage(),
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
    );
  }
}