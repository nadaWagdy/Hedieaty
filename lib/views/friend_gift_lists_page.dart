import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/models/enums.dart';
import 'package:hedieaty/services/notification_service.dart';
import 'package:hedieaty/views/common_widgets.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:hedieaty/views/gift_details_page.dart';
import '../controllers/gift_controller.dart';
import '../controllers/user_controller.dart';
import '../models/event.dart';
import '../services/auth.dart';

class FriendsGiftListPage extends StatefulWidget {
  final String friendName;
  final String eventName;
  final String eventId;
  final String friendId;
  final Event friendEvent;

  const FriendsGiftListPage({Key? key, required this.friendName, required this.eventName, required this.eventId, required this.friendId, required this.friendEvent}) : super(key: key);

  @override
  _FriendsGiftListPageState createState() => _FriendsGiftListPageState();
}

class _FriendsGiftListPageState extends State<FriendsGiftListPage> {
  late List<Gift> gifts;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGifts();
    _addGiftsListener();
  }

  void pledgeGift(int index) {
    final userId = Auth().currentUser?.uid;
    setState(() {
      if (gifts[index].status != GiftStatus.pledged) {
        gifts[index].status = GiftStatus.pledged;
        GiftController.updateStatus(widget.friendId, widget.eventId, gifts[index].id, GiftStatus.pledged, userId!);
        UserController.addPledgedGift(userId, widget.friendId, widget.eventId, gifts[index].id);
        sendPledgedNotification(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${gifts[index].name} pledged!')),
        );
      }
    });
  }

  Future<void> sendPledgedNotification(int index) async {
    try {
      bool isEnabled = await UserController.isNotificationEnabled(widget.friendId);
      if(!isEnabled){
        return;
      }
      final friendToken = await UserController.getNotificationToken(widget.friendId);
      final userId = Auth().currentUser?.uid;
      final userName = await UserController.getUserNameById(userId!);
      if (friendToken != null) {
        await NotificationService().sendNotification(
          token: friendToken,
          title: 'Gift Pledged!',
          body: '$userName pledged your gift: ${gifts[index].name}',
        );
      } else {
        print('Friend\'s FCM token not found.');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> _loadGifts() async {
    try {
      gifts = await GiftController.fetchFromFirebase(widget.eventId, widget.friendId);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching gifts: $e');
    }
  }

  StreamSubscription<DatabaseEvent>? giftsStream;

  void _addGiftsListener() {
    final ref = FirebaseDatabase.instance.ref('users/${widget.friendId}/events/${widget.eventId}/gifts');
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
      appBar: createSubPageAppBar('${widget.friendName}\'s ${widget.eventName} Gifts'),
      body: isLoading ?
      Center(child: CircularProgressIndicator(color: appColors['primary'],),)
      : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.friendEvent.name,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: appColors['primary'],
                    fontFamily: 'lxgw'
                ),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Date:',
              style: TextStyle(fontSize: 20, color: appColors['primary'], fontWeight: FontWeight.bold, fontFamily: 'lxgw'),
            ),
            SizedBox(height: 6,),
            Text(
              '${widget.friendEvent.date.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 18, color: appColors['buttonText'], fontFamily: 'lxgw'),
            ),
            SizedBox(height: 6,),
            Text(
              'Location:',
              style: TextStyle(fontSize: 20, color: appColors['primary'], fontWeight: FontWeight.bold, fontFamily: 'lxgw'),
            ),
            SizedBox(height: 6,),
            Text(
              '${widget.friendEvent.location}',
              style: TextStyle(fontSize: 18, color: appColors['buttonText'], fontFamily: 'lxgw'),
            ),
            SizedBox(height: 6),
            Text(
              'Event Description:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: appColors['primary'], fontFamily: 'lxgw'),
            ),
            SizedBox(height: 8),
            Text(
              widget.friendEvent.description,
              style: TextStyle(fontSize: 16, color: appColors['buttonText'], fontFamily: 'lxgw'),
            ),
            SizedBox(height: 20),
            Text(
              'Gifts:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: appColors['primary'], fontFamily: 'lxgw'),
            ),
            SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                itemCount: gifts.length,
                itemBuilder: (context, index) {
                  final gift = gifts[index];
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
                          backgroundImage:getImageProvider(gift.imagePath),
                        ),
                        title: Text(
                          gift.name,
                          style: TextStyle(
                            color: appColors['primary'],
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        subtitle:Column(
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
                          ],
                        ),
                        trailing: gift.status == GiftStatus.available ? IconButton(
                          icon: Icon(
                            Icons.add_box_rounded,
                            color: appColors['primary'],
                          ),
                          onPressed: gift.status == GiftStatus.available
                              ? () => pledgeGift(index)
                              : null,
                        ) : SizedBox(height: 0,),
                        tileColor: getGiftStatusColor(gift.status),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GiftDetailsPage(giftId: gift.id, eventId: widget.eventId, userId: widget.friendId),
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

  @override
  void dispose() {
    giftsStream?.cancel();
    super.dispose();
  }

}
