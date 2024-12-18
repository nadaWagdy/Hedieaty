import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/models/enums.dart';
import 'package:hedieaty/services/notification_service.dart';
import 'package:hedieaty/views/common_widgets.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:hedieaty/models/user.dart' as user_model;
import '../services/auth.dart';

class FriendsGiftListPage extends StatefulWidget {
  final String friendName;
  final String eventName;
  final String eventId;
  final String friendId;

  const FriendsGiftListPage({Key? key, required this.friendName, required this.eventName, required this.eventId, required this.friendId}) : super(key: key);

  @override
  _FriendsGiftListPageState createState() => _FriendsGiftListPageState();
}

class _FriendsGiftListPageState extends State<FriendsGiftListPage> {
  late List<Gift> gifts;
  bool isLoading = true;
  String _defaultGiftImage = 'assets/images/default.png';

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
        Gift.updateStatus(widget.friendId, widget.eventId, gifts[index].id, GiftStatus.pledged, userId!);
        user_model.User.addPledgedGift(userId, widget.friendId, widget.eventId, gifts[index].id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${gifts[index].name} pledged!')),
        );
      }
    });
  }

  Future<void> _loadGifts() async {
    try {
      gifts = await Gift.fetchFromFirebase(widget.eventId, widget.friendId);
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
      CircularProgressIndicator()
      : Column(
        children: [
          SizedBox(height: 20,),
          Expanded(
            child: ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                print('testtttt');
                print(gift.imagePath != 'assets/images/default_profile.png');
                print(gift.imagePath);
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
                        backgroundImage: gift.imagePath != _defaultGiftImage
                            ? FileImage(File(gift.imagePath!))
                            : AssetImage(gift.imagePath!)
                        as ImageProvider,
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
                      trailing: IconButton(
                        icon: Icon(
                          gift.status != GiftStatus.available ? Icons.check_box : Icons.add_box_rounded,
                          color: appColors['primary'],
                        ),
                        onPressed: gift.status == GiftStatus.available
                            ? () => pledgeGift(index)
                            : null,
                      ),
                      tileColor: getGiftStatusColor(gift.status),
                      onTap: () {

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

  @override
  void dispose() {
    giftsStream?.cancel();
    super.dispose();
  }

}
