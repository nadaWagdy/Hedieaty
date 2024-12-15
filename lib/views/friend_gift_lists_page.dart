import 'package:flutter/material.dart';
import 'package:hedieaty/models/enums.dart';
import 'package:hedieaty/views/common_widgets.dart';
import 'package:hedieaty/models/gift.dart';

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

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  void pledgeGift(int index) {
    setState(() {
      if (gifts[index].status != GiftStatus.pledged) {
        gifts[index].status = GiftStatus.pledged;
        Gift.updateStatus(widget.friendId, widget.eventId, gifts[index].id, GiftStatus.pledged);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${gifts[index].name} pledged!')),
        );
      } else {
        gifts[index].status = GiftStatus.available;
        Gift.updateStatus(widget.friendId, widget.eventId, gifts[index].id, GiftStatus.available);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${gifts[index].name} unpledged!')),
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
                          gift.status == GiftStatus.pledged ? Icons.check_box : Icons.add_box_rounded,
                          color: appColors['primary'],
                        ),
                        onPressed: gift.status == GiftStatus.purchased
                            ? null
                            : () => pledgeGift(index),
                      ),
                      tileColor: gift.status == GiftStatus.pledged ? appColors['pledged'] : null,
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
}
