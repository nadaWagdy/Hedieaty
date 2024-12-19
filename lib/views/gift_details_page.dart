import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:hedieaty/views/common_widgets.dart';

class GiftDetailsPage extends StatefulWidget {
  final String giftId;
  final String eventId;
  final String userId;

  const GiftDetailsPage({
    Key? key,
    required this.giftId,
    required this.eventId,
    required this.userId,
  }) : super(key: key);

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  Gift? gift;
  bool isLoading = true;
  StreamSubscription<DatabaseEvent>? giftStream;
  final _defaultImagePath = 'assets/images/default.png';

  @override
  void initState() {
    super.initState();
    _loadGiftDetails();
    _addGiftListener();
  }

  Future<void> _loadGiftDetails() async {
    try {
      gift = await Gift.getGiftById(widget.userId, widget.eventId, widget.giftId);
        setState(() {
          isLoading = false;
        });
    } catch (e) {
      print('Error loading gift details: $e');
    }
  }

  void _addGiftListener() {
    final ref = FirebaseDatabase.instance.ref(
      'users/${widget.userId}/events/${widget.eventId}/gifts/${widget.giftId}',
    );
    giftStream = ref.onValue.listen((event) async {
      if (event.snapshot.exists) {
        gift = await Gift.getGiftById(widget.userId, widget.eventId, widget.giftId);
        setState(() {
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createSubPageAppBar("Gift Details"),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: appColors['primary'],))
          : gift != null
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: appColors['background'],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              if (gift!.imagePath != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: gift!.imagePath != _defaultImagePath
                      ? Image.file(File(gift!.imagePath!))
                      : Image.asset(gift!.imagePath!),
                ),
              ListTile(
                title: Center(
                  child: Text(
                    gift!.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: appColors['primary'],
                        fontFamily: 'lxgw'
                    ),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20,),
                    Text('Description: ',
                      style: TextStyle(
                        color: appColors['primary'],
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        fontFamily: 'lxgw'
                      ),),
                    Text(
                      gift!.description ?? 'No description available',
                      style: TextStyle(fontSize: 18, fontFamily: 'lxgw', color: appColors['buttonText']),
                    ),
                    SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                          text: 'Category: ',
                          style: TextStyle(fontSize: 22, color: appColors['primary'], fontWeight: FontWeight.bold, fontFamily: 'lxgw'),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${gift!.category?.name ?? 'Unknown'}',
                              style: TextStyle(fontSize: 20, color: appColors['buttonText'], fontWeight: FontWeight.normal),
                            )
                          ]
                      ),
                    ),
                    SizedBox(height: 10,),
                    RichText(
                      text: TextSpan(
                          text: 'Price: ',
                          style: TextStyle(fontSize: 22, color: appColors['primary'], fontWeight: FontWeight.bold, fontFamily: 'lxgw'),
                          children: <TextSpan>[
                            TextSpan(
                              text: '\$${gift!.price?.toStringAsFixed(2) ?? 'N/A'}',
                              style: TextStyle(fontSize: 20, color: appColors['buttonText'], fontWeight: FontWeight.normal),
                            )
                          ]
                      ),
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                          text: 'Status: ',
                          style: TextStyle(fontSize: 22, color: appColors['primary'], fontWeight: FontWeight.bold, fontFamily: 'lxgw'),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${gift!.status.name}',
                              style: TextStyle(fontSize: 20, color: getGiftStatusTextColor(gift!.status),),
                            )
                          ]
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
          : Center(child: Text('Gift not found.')),
    );
  }

  @override
  void dispose() {
    giftStream?.cancel();
    super.dispose();
  }
}
