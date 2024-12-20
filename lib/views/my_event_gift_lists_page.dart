import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hedieaty/models/enums.dart';
import 'package:hedieaty/models/event.dart' as event_model;
import 'package:hedieaty/models/gift.dart';
import 'package:hedieaty/views/gift_details_page.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/user_controller.dart';
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
  final _userId = FirebaseAuth.instance.currentUser?.uid;

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
          String? name = await UserController.getUserNameById(pledged_gift!.pledgedBy!);
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

  Future<void> editGift(Gift gift) async {
    final isAllowed = gift.status == GiftStatus.available;
    if (!isAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You cannot edit this gift because it is ${gift.status==GiftStatus.pledged ? 'pledged' : 'purchased' }',
            style: TextStyle(fontSize: 18),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController(text: gift.name);
    final TextEditingController descriptionController = TextEditingController(text: gift.description ?? '');
    final TextEditingController priceController = TextEditingController(text: gift.price.toString());
    String? selectedCategory = gift.category?.name;
    String _giftImagePath = gift.imagePath ?? _defaultGiftImagePath;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Gift',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'lxgw',
            color: appColors['primary'],
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: textFieldsDecoration('Gift Name'),
                style: TextStyle(color: Colors.black),
                cursorColor: appColors['primary'],
              ),
              SizedBox(height: 20),
              TextField(
                controller: descriptionController,
                decoration: textFieldsDecoration('Description'),
                style: TextStyle(color: Colors.black),
                cursorColor: appColors['primary'],
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: GiftCategory.values.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value;
                },
                decoration: textFieldsDecoration('Category'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: priceController,
                decoration: textFieldsDecoration('Price'),
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
                cursorColor: appColors['primary'],
              ),
              SizedBox(height: 20,),
              Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

                      if (pickedImage != null) {
                        setState(() {
                          _giftImagePath = pickedImage.path;
                        });
                      }
                    },
                    child: Text('Change Gift Image'),
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
                  )
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: appColors['primary'])),
          ),
          ElevatedButton(
            onPressed: () async {
              gift.name = nameController.text;
              gift.description = descriptionController.text.isNotEmpty ? descriptionController.text : null;
              gift.price = double.tryParse(priceController.text) ?? gift.price;
              gift.category = GiftCategory.values.firstWhere(
                    (category) => category.name == selectedCategory,
                orElse: () => gift.category!,
              );
              gift.imagePath = _giftImagePath;

              final userId = FirebaseAuth.instance.currentUser?.uid;
              await gift.updateInFirebase(userId!, widget.eventId);

              setState(() {
                int index = gifts.indexWhere((g) => g.id == gift.id);
                if (index != -1) {
                  gifts[index] = gift;
                }
              });

              Navigator.of(context).pop();
            },
            child: Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors['primary'],
              foregroundColor: appColors['buttonText'],
              shadowColor: Colors.blueGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  bool isDeleteAllowed(Gift gift) {
    return gift.status == GiftStatus.available;
  }

  void deleteGift(Gift gift) {
    final isAllowed = gift.status == GiftStatus.available;
    if (!isAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You cannot delete this gift because it is already pledged or purchased',
            style: TextStyle(fontSize: 18),
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }
    final userId = FirebaseAuth.instance.currentUser?.uid;
    Gift.deleteFromFirebase(userId!, widget.eventId, gift.id);
    setState(() {
      gifts.removeWhere((e) => e.id == gift.id);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createSubPageAppBar(isLoading == false ? event!.name : ''),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: appColors['primary'],))
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
            SizedBox(height: 6),
            Text(
              'Date:',
              style: TextStyle(fontSize: 20, color: appColors['primary'], fontWeight: FontWeight.bold, fontFamily: 'lxgw'),
            ),
            SizedBox(height: 6,),
            Text(
              '${event!.date.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 18, color: appColors['buttonText'], fontFamily: 'lxgw'),
            ),
            SizedBox(height: 6,),
            Text(
              'Location:',
              style: TextStyle(fontSize: 20, color: appColors['primary'], fontWeight: FontWeight.bold, fontFamily: 'lxgw'),
            ),
            SizedBox(height: 6,),
            Text(
              '${event!.location}',
              style: TextStyle(fontSize: 18, color: appColors['buttonText'], fontFamily: 'lxgw'),
            ),
            SizedBox(height: 6),
            Text(
              'Event Description:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: appColors['primary'], fontFamily: 'lxgw'),
            ),
            SizedBox(height: 8),
            Text(
              event!.description,
              style: TextStyle(fontSize: 16, color: appColors['buttonText'], fontFamily: 'lxgw'),
            ),
            SizedBox(height: 20),

            gifts.length == 0 ? SizedBox(height: 0,) : Text(
              "Gifts for ${event!.name}",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: appColors['primary'],
                fontFamily: 'lxgw'
              ),
            ),
            SizedBox(height: 20),
            gifts.length == 0 ?
            Center(
              child: Text('No Gifts For This Event Yet. Add Some Gifts!',
                style: TextStyle(
                    color: appColors['primary'],
                    fontFamily: 'lxgw',
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
            ) :
            Expanded(
              child: ListView.builder(
                itemCount: gifts.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(gifts[index].id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      deleteGift(gifts[index]);
                    },
                    confirmDismiss: (direction) async {
                      final bool? confirm = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Deletion'),
                            content: Text('Are you sure you want to delete this item?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('Cancel', style: TextStyle(color: appColors['primary']),),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text('Delete'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appColors['primary'],
                                  foregroundColor: appColors['buttonText'],
                                  shadowColor: Colors.blueGrey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      bool delete = confirm! && isDeleteAllowed(gifts[index]);
                      if(!isDeleteAllowed(gifts[index])) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text( 'You cannot delete this gift because it is already ${gifts[index].status==GiftStatus.pledged ? 'pledged' : 'purchased' }',
                              style: TextStyle(fontSize: 18),),
                            duration: Duration(seconds: 5),
                          ),
                        );
                      }
                      return delete;
                    },
                    background: Container(
                      color: appColors['primary'],
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                      child: Card(
                        color: getGiftStatusColor(gifts[index].status),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GiftDetailsPage(giftId: gifts[index].id, eventId: widget.eventId, userId: _userId!),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundImage: getImageProvider(gifts[index].imagePath),
                            radius: 40,
                          ),
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
                                '${gifts[index].status == GiftStatus.pledged ? 'Pledged By' : 'Purchased By'}: ${_pledgedby[index]}',
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
                              ),
                            ],
                          ),
                          trailing: gifts[index].status == GiftStatus.available ? IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: appColors['primary'],
                            ),
                            onPressed: (){
                              editGift(gifts[index]);
                            },
                          ) : SizedBox(height: 0,),
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