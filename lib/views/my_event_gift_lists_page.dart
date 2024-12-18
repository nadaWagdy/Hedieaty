import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hedieaty/models/enums.dart';
import 'package:hedieaty/models/event.dart' as event_model;
import 'package:hedieaty/models/gift.dart';
import 'package:hedieaty/models/user.dart' as user_model;
import 'common_widgets.dart';

class MyEventGiftsListPage extends StatefulWidget {
  final String eventId;

  MyEventGiftsListPage({required this.eventId});

  @override
  _MyEventGiftsListPageState createState() => _MyEventGiftsListPageState();
}

class _MyEventGiftsListPageState extends State<MyEventGiftsListPage> {
  event_model.Event? event;
  late List<Gift> gifts = [];
  bool isLoading = true;
  final List<String> _pledgedby = [];
  final String _defaultGiftImagePath = 'assets/images/default.png';

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
    _loadGifts();
    _addGiftsListener();
  }

  Future<void> _loadEventDetails() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final ref = FirebaseDatabase.instance.ref('users/$userId/events/${widget.eventId}');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<Object?, Object?>;
        final eventMap = Map<String, dynamic>.from(data);

        setState(() {
          event = event_model.Event.fromFirebaseMap(eventMap);
        });
      } else {
        print('Event not found');
      }
    } catch (e) {
      print('Error fetching event: $e');
    }
  }


  Future<void> _loadGifts() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      gifts = await Gift.fetchFromFirebase(widget.eventId, userId!);
      for (Gift gift in gifts) {
        if (gift.status != GiftStatus.available) {
          final Gift? pledged_gift = await Gift.getGiftById(userId, widget.eventId, gift.id);
          String? name = await user_model.User.getUserNameById(pledged_gift!.pledgedBy!);
          _pledgedby.add(name!);
        } else {
          _pledgedby.add('');
        }
      }
        setState(() {
          isLoading = false;
        });
    } catch (e) {
      print('Error fetching gifts: $e');
    }
  }

  StreamSubscription<DatabaseEvent>? giftsStream;

  void _addGiftsListener() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final ref = FirebaseDatabase.instance.ref('users/$userId/events/${widget.eventId}/gifts');
    giftsStream = ref.onValue.listen((event) {
      if (event.snapshot.exists) {
        final Map<String, dynamic> giftsMap = Map<String, dynamic>.from(event.snapshot.value as Map<Object?, Object?>);
        setState(() {
          gifts = Gift.parseGifts(giftsMap);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createSubPageAppBar(isLoading == false ? event!.name : ''),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                event!.name,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: appColors['primary'],
                    fontFamily: 'lxgw'
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Date:',
              style: TextStyle(fontSize: 20, color: appColors['primary'], fontWeight: FontWeight.bold, fontFamily: 'lxgw'),
            ),
            SizedBox(height: 10,),
            Text(
              '${event!.date.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 20, color: appColors['buttonText'], fontFamily: 'lxgw'),
            ),
            SizedBox(height: 20,),
            Text(
              'Location:',
              style: TextStyle(fontSize: 20, color: appColors['primary'], fontWeight: FontWeight.bold, fontFamily: 'lxgw'),
            ),
            SizedBox(height: 10,),
            Text(
              '${event!.location}',
              style: TextStyle(fontSize: 20, color: appColors['buttonText'], fontFamily: 'lxgw'),
            ),
            SizedBox(height: 20),
            Text(
              'Event Description:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: appColors['primary'], fontFamily: 'lxgw'),
            ),
            SizedBox(height: 8),
            Text(
              event!.description,
              style: TextStyle(fontSize: 20, color: appColors['buttonText'], fontFamily: 'lxgw'),
            ),
            SizedBox(height: 20),

            gifts.length == 0 ? SizedBox(height: 0,) : Text(
              "Gifts for ${event!.name}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: appColors['primary'],
                fontFamily: 'lxgw'
              ),
            ),
            SizedBox(height: 20),
            gifts.length == 0 ?
            Center(
              child: Text('No Gifts For This Event Yet. Add Some Gifts Frist',
                style: TextStyle(
                    color: appColors['buttonText'],
                    fontFamily: 'lxgw',
                    fontWeight: FontWeight.bold,
                    fontSize: 30
                ),
                textAlign: TextAlign.center,
              ),
            ) :
            Expanded(
              child: ListView.builder(
                itemCount: gifts.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: getGiftStatusColor(gifts[index].status),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: Icon(CupertinoIcons.gift_fill, size: 30,),
                      title: Text(
                        gifts[index].name,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'lxgw'
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gifts[index].description ?? 'No description available',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'lxgw',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Category: ${gifts[index].category?.name ?? "Unknown"}',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'lxgw',
                                color: appColors['secondary'],
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            'Status: ${gifts[index].status.name}',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'lxgw',
                                color: appColors['secondary'],
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          gifts[index].status != GiftStatus.available ?
                          Text(
                            'Pledged By: ${_pledgedby[index]}',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'lxgw',
                                color: appColors['secondary'],
                                fontWeight: FontWeight.bold
                            ),
                          ) : SizedBox(height: 0,),
                          Text(
                            'Price: \$${gifts[index].price ?? 0.0}',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'lxgw',
                                fontWeight: FontWeight.bold
                            ),
                          )
                        ],
                      ),
                      trailing: CircleAvatar(
                        backgroundImage: gifts[index].imagePath != _defaultGiftImagePath
                            ? FileImage(File(gifts[index].imagePath!))
                            : AssetImage(gifts[index].imagePath!)
                        as ImageProvider,
                        radius: 40,
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

  @override
  void dispose() {
    giftsStream?.cancel();
    super.dispose();
  }
}
