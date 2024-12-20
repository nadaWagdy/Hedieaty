import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import 'common_widgets.dart';
import 'friend_gift_lists_page.dart';
import 'package:hedieaty/models/event.dart' as event_model;
import 'package:hedieaty/controllers/user_controller.dart';
import 'package:hedieaty/models/user.dart';

class EventListPage extends StatefulWidget {
  final String friendId;

  const EventListPage({Key? key, required this.friendId}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<event_model.Event> friendEvents = [];
  List<event_model.Event> filteredEvents = [];
  bool isLoading = true;
  User? _friend;
  DateTimeRange? selectedDateRange;
  String? selectedCategory;

  static const IconData giftIcon = IconData(0xf689, fontFamily: 'lxgw', );

  @override
  void initState() {
    super.initState();
    fetchEvents(widget.friendId);
    _fetchFriendData(widget.friendId);
  }

  Future<void> fetchEvents(String id) async {
    try {
      final fetchedEvents = await EventController.fetchFromFirebase(id);
      setState(() {
        friendEvents = fetchedEvents;
        filteredEvents = fetchedEvents;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchFriendData(String id) async {
    try {
      User? user = await UserController.fetchFromFirebase(id);

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

  void _filterEvents() {
    setState(() {
      filteredEvents = friendEvents.where((event) {
        final matchesCategory = selectedCategory == null || event.category.name == selectedCategory;
        final matchesDateRange = selectedDateRange == null ||
            (event.date.isAfter(selectedDateRange!.start) && event.date.isBefore(selectedDateRange!.end));
        return matchesCategory && matchesDateRange;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isLoading ? createSubPageAppBar('') : createSubPageAppBar('${_friend!.name}\'s Events'),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: appColors['primary']))
          : Padding(
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
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    hint: Text("Filter by Category", style: TextStyle(
                      color: appColors['primary'],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),),
                    style: TextStyle(
                      color: appColors['primary'],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    decoration: TextFieldDecoration.searchInputDecoration('Filter by Category'),
                    value: selectedCategory,
                    items: friendEvents
                        .map((e) => e.category.name)
                        .toSet()
                        .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                        _filterEvents();
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                    color: appColors['primary'],
                    onPressed: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData(
                              colorScheme: ColorScheme.light(
                                primary: appColors['primary']!,
                                onPrimary: appColors['buttonText']!,
                                onSurface: appColors['background']!,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: appColors['primary']!,
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (range != null) {
                        setState(() {
                          selectedDateRange = range;
                          _filterEvents();
                        });
                      }
                    },
                    icon: Icon(Icons.calendar_month, color: appColors['primary'], size: 40,)),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Card(
                      color: appColors['listCard'],
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(
                          event.name,
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
                                style: TextStyle(
                                  fontSize: 18,
                                  color: appColors['primary'],
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'lxgw',
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '${event.category.name}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: appColors['background'],
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: 'Status: ',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: appColors['primary'],
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'lxgw',
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '${event.status.name}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: appColors['background'],
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: 'Date: ',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: appColors['primary'],
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'lxgw',
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '${event.date.toLocal().toString().split(' ')[0]}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: appColors['background'],
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: 'Location: ',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: appColors['primary'],
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'lxgw',
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '${event.location}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: appColors['background'],
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            CupertinoIcons.gift_fill,
                            color: appColors['primary'],
                            size: 40,
                          ),
                          onPressed: () {},
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FriendsGiftListPage(
                                friendId: _friend!.id,
                                eventId: event.id,
                                friendName: _friend!.name,
                                eventName: event.name,
                                friendEvent: event,
                              ),
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
