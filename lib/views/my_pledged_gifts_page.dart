import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:hedieaty/views/gift_details_page.dart';
import '../controllers/event_controller.dart';
import '../controllers/gift_controller.dart';
import '../controllers/user_controller.dart';
import '../models/enums.dart';
import '../services/auth.dart';
import '../services/notification_service.dart';
import 'common_widgets.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  List<Gift> myPledgedGifts = [];
  bool isLoading = true;
  List<String> friendNames = [];
  List<DateTime> eventsDates = [];
  List<String> friendIds = [];
  List<String> eventIds = [];


  @override
  void initState() {
    super.initState();
    _loadAllPledgedGifts();
  }

  void _loadAllPledgedGifts() async {
    try {
      final userId = Auth().currentUser?.uid;
      List<Map<String, String>> pledgedGifts = await UserController.getAllPledgedGifts(userId!);

      for (var gift in pledgedGifts) {
        print('Friend ID: ${gift['friendId']}, Event ID: ${gift['eventId']}, Gift ID: ${gift['giftId']}');
        final newgift = await GiftController.getGiftById(gift['friendId']!, gift['eventId']!, gift['giftId']!);
        myPledgedGifts.add(newgift!);
        String? friendName = await UserController.getUserNameById(gift['friendId']!);
        DateTime? eventDate = await EventController.getEventDateById(gift['friendId']!, gift['eventId']!);
        friendNames.add(friendName!);
        eventsDates.add(eventDate!);
        friendIds.add(gift['friendId']!);
        eventIds.add(gift['eventId']!);
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching pledged gifts: $e');
    }
  }

  void unPledgeGift(int index) {
    final userId = Auth().currentUser?.uid;
    print(myPledgedGifts[index].name);
    myPledgedGifts[index].status = GiftStatus.available;
    GiftController.updateStatus(friendIds[index], eventIds[index], myPledgedGifts[index].id, GiftStatus.available, '');
    UserController.removePledgedGift(userId!, myPledgedGifts[index].id);
    sendUnPledgedNotification(friendIds[index], myPledgedGifts[index].name);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${myPledgedGifts[index].name} unpledged!')),
    );
    setState(() {
      myPledgedGifts.removeWhere((e) => e.id == myPledgedGifts[index].id);
    });
  }

  Future<void> sendUnPledgedNotification(String friendID, String giftName) async {
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
          title: 'Gift UnPledged!',
          body: '$userName removed the pledge on your gift: ${giftName}',
        );
      } else {
        print('Friend\'s FCM token not found.');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  void purchaseGift(int index) {
    final userId = Auth().currentUser?.uid;
    setState(() {
      myPledgedGifts[index].status = GiftStatus.purchased;
      GiftController.updateStatus(friendIds[index], eventIds[index], myPledgedGifts[index].id, GiftStatus.purchased, userId!);
      sendPurchasedNotification(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${myPledgedGifts[index].name} unpledged!')),
      );
    });
  }

  Future<void> sendPurchasedNotification(int index) async {
    try {
      bool isEnabled = await UserController.isNotificationEnabled(friendIds[index]);
      if(!isEnabled){
        return;
      }
      final friendToken = await UserController.getNotificationToken(friendIds[index]);
      final userId = Auth().currentUser?.uid;
      final userName = await UserController.getUserNameById(userId!);
      if (friendToken != null) {
        await NotificationService().sendNotification(
          token: friendToken,
          title: 'Gift Purchased!',
          body: '$userName purchased your gift: ${myPledgedGifts[index].name}',
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
        title: Text('My Pledged Gifts'),
        backgroundColor: appColors['primary'],
      ),
      body: isLoading ?
      Center(child: CircularProgressIndicator(color: appColors['primary'],),)
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20,),
          myPledgedGifts.isNotEmpty ? Expanded(
            child: ListView.builder(
              itemCount: myPledgedGifts.length,
              itemBuilder: (context, index) {
                final gift = myPledgedGifts[index];
                final friendName = friendNames[index];
                final eventDate = eventsDates[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    color: appColors['listCard'],
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GiftDetailsPage(giftId: gift.id, eventId: eventIds[index], userId: friendIds[index]),
                          ),
                        );
                      },
                      tileColor: gift.status == GiftStatus.purchased ? Colors.amberAccent : null,
                      title: Text(
                        gift.name,
                        style: TextStyle(
                          color: appColors['primary'],
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${gift.status == GiftStatus.pledged ? 'Pledged' : 'Purchased'} to: $friendName',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text('Due Date: ${eventDate.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      trailing: gift.status == GiftStatus.purchased ? Icon(Icons.check) : PopupMenuButton<String>(
                        onSelected: (String result) {
                          if (result == 'Unpledge') {
                            unPledgeGift(index);
                          } else if (result == 'Purchase') {
                            purchaseGift(index);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'Unpledge',
                            child: Text('Unpledge', style: TextStyle(fontFamily: 'lxgw', fontWeight: FontWeight.bold, color: appColors['primary'], fontSize: 20),),
                          ),
                           PopupMenuItem<String>(
                            value: 'Purchase',
                            child: Text('Mark as Purchased', style: TextStyle(fontFamily: 'lxgw', fontWeight: FontWeight.bold, color: appColors['primary'], fontSize: 20),),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ) : Center(
            child: Text('You Have Not Pledged Any Gifts Yet', style: TextStyle(color: appColors['primary'], fontWeight: FontWeight.bold, fontSize: 20),),
          ),
        ],
      ),
    );
  }
}