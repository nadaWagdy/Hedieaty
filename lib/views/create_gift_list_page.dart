import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:image_picker/image_picker.dart';
import '../models/enums.dart';
import '../services/db_service.dart';
import 'common_widgets.dart';

class CreateGiftListPage extends StatefulWidget {
  @override
  _CreateGiftListPageState createState() => _CreateGiftListPageState();
}

class _CreateGiftListPageState extends State<CreateGiftListPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  List<String> _categories = ['electronics', 'books', 'clothing', 'other'];

  String? _selectedEventId;
  String? selectedEvent;
  String? selectedCategory;
  List<String> events = [];
  List<String> eventsIds = [];
  List<Gift> savedGifts = [];

  final ImagePicker _picker = ImagePicker();
  String _giftImagePath = 'assets/images/default.png';

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadSavedGifts();
  }

  Future<void> _loadEvents() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final ref = FirebaseDatabase.instance.ref('users/$userId/events');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        setState(() {
          events = (snapshot.value as Map).values
              .map<String>((e) => e['name'] as String)
              .toList();
          eventsIds = (snapshot.value as Map).values
              .map<String>((e) => e['id'] as String)
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading events',
          style: TextStyle(fontSize: 18),
        )),
      );
    }
  }

  Future<void> _loadSavedGifts() async {
    final drafts = await Gift.getDrafts();
    setState(() {
      savedGifts = drafts;
    });
  }

  Future<void> _addGift() async {

    if (!_formKey.currentState!.validate()) return;

    _selectedEventId = eventsIds[events.indexOf(selectedEvent!)];

    if(selectedEvent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select an event to add the gift',
          style: TextStyle(fontSize: 18),
        )),
      );
      return;
    }
    if(selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select a category to add the gift',
          style: TextStyle(fontSize: 18),
        ),),
      );
      return;
    }

    final gift = Gift(
      name: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: selectedCategory != null
          ? GiftCategory.values.firstWhere((e) => e.name == selectedCategory)
          : null,
      price: double.tryParse(_priceController.text.trim()),
      status: GiftStatus.available,
      eventID: _selectedEventId ?? '',
      imagePath: _giftImagePath
    );

    await Gift.saveDraft(gift);
    setState(() {
      savedGifts.add(gift);
    });

    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    selectedCategory = null;
    selectedEvent = null;
    _giftImagePath = 'assets/images/default.png';
  }

  Future<void> _saveGiftList() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    for (Gift gift in savedGifts) {
      await Gift.publishToFirebase(gift, gift.eventID, userId!);
    }

    final db = await DatabaseService().database;
    await db.delete('DraftGifts');
    setState(() {
      savedGifts.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gift list published successfully!',
        style: TextStyle(fontSize: 18),
      )),
    );
  }

  Future<void> _uploadGiftImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
      _giftImagePath = pickedImage.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createSubPageAppBar('Create Gift List'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  decoration: TextFieldDecoration.searchInputDecoration('Select Event'),
                  style: TextStyle(
                    color: appColors['primary'],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  value: selectedEvent,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedEvent = newValue;
                    });
                  },
                  items: events.map((String event) {
                    return DropdownMenuItem<String>(
                      value: event,
                      child: Text(event),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: TextFieldDecoration.searchInputDecoration('Title'),
                  style: TextStyle(color: appColors['buttonText']),
                  cursorColor: appColors['buttonText'],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: TextFieldDecoration.searchInputDecoration('Description'),
                  style: TextStyle(color: appColors['buttonText']),
                  cursorColor: appColors['buttonText'],
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _uploadGiftImage,
                    child: Text('Choose Gift Image'),
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
                ),
                SizedBox(height: 10,),
                _giftImagePath == 'assets/images/default.png' ? SizedBox(height: 0,) : 
                    Center(
                          child: Text('Gift Image Selected', style: TextStyle(color: appColors['primary'], fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'lxgw'),)
                    ),
                SizedBox(height: 20,),
                DropdownButtonFormField<String>(
                  decoration: TextFieldDecoration.searchInputDecoration('Category'),
                  style: TextStyle(
                    color: appColors['primary'],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  value: selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _priceController,
                  decoration: TextFieldDecoration.searchInputDecoration('Price'),
                  style: TextStyle(color: appColors['buttonText']),
                  cursorColor: appColors['buttonText'],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _addGift,
                    icon: Icon(Icons.add),
                    label: Text('Add Gift'),
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
                  ),
                ),
                SizedBox(height: 20),
                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: savedGifts.length,
                  itemBuilder: (context, index) {
                    final gift = savedGifts[index];
                    return Card(
                      color: appColors['listCard'],
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(gift.name),
                        subtitle: Text('Category: ${gift.category?.name ?? 'None'}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            final db = await DatabaseService().database;
                            await db.delete('DraftGifts', where: 'id = ?', whereArgs: [gift.id]);
                            setState(() {
                              savedGifts.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(),
                ),
                SizedBox(height: 20),
                Center(
                  child: savedGifts.isEmpty == false ? ElevatedButton(
                    onPressed: _saveGiftList,
                    child: Text('Save Gift List'),
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
                  ) : SizedBox(height: 10,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
