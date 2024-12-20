import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/views/my_event_gift_lists_page.dart';
import '../controllers/event_controller.dart';
import '../controllers/gift_controller.dart';
import '../models/enums.dart';
import 'common_widgets.dart';
import 'package:hedieaty/models/event.dart' as event_model;
import 'create_event_page.dart';

class MyEventsPage extends StatefulWidget {
  @override
  _MyEventsPageState createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  String selectedSortOption = 'Name';
  List<String> sortOptions = ['Name', 'Category', 'Status'];

  List<event_model.Event> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final fetchedEvents = await EventController.fetchFromFirebase(userId!);
      setState(() {
        events = fetchedEvents;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error fetching events: $error',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
  }

  Future<bool> checkIfPledgedOrPurchased(String eventId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final eventGifts = await GiftController.fetchFromFirebase(eventId, userId!);

    return eventGifts.any((gift) => gift.status == GiftStatus.pledged || gift.status == GiftStatus.purchased);
  }

  Future<void> editEvent(event_model.Event event) async {

    final isAllowed = await checkIfPledgedOrPurchased(event.id);
    if (isAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You cannot edit this event because it contains pledged or purchased gifts',
            style: TextStyle(fontSize: 18),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController(text: event.name);
    final TextEditingController locationController = TextEditingController(text: event.location);
    final TextEditingController descriptionController = TextEditingController(text: event.description);
    DateTime selectedDate = event.date;
    String? selectedCategory = event.category.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Event',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'lxgw', color: appColors['primary']),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: textFieldsDecoration('Event Name'),
              style: TextStyle(color: Colors.black),
              cursorColor: appColors['primary'],
            ),
            SizedBox(height: 5,),
            TextField(
              controller: descriptionController,
              decoration: textFieldsDecoration('Event Description'),
              style: TextStyle(color: Colors.black),
              cursorColor: appColors['primary'],
            ),
            SizedBox(height: 5),
            TextField(
              controller: locationController,
              decoration: textFieldsDecoration('Location'),
              style: TextStyle(color: Colors.black),
              cursorColor: appColors['primary'],
            ),
            SizedBox(height: 5,),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: EventCategory.values.map((category) {
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
            SizedBox(height: 5),
            Center(
              child: TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
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
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: Text(
                  'Select Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(color: appColors['primary'], fontSize: 16),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: appColors['primary'])),
          ),
          ElevatedButton(
            onPressed: () async {
              event.name = nameController.text;
              event.location = locationController.text;
              event.description = descriptionController.text;
              event.date = selectedDate;
              if (selectedDate.year == DateTime.now().year &&
                  selectedDate.month == DateTime.now().month &&
                  selectedDate.day == DateTime.now().day)
                event.status = EventStatus.current;
              else
                event.status = EventStatus.upcoming;

              event.category = EventCategory.values.firstWhere(
                    (category) => category.name == selectedCategory,
                orElse: () => event.category,
              );
              final userId = FirebaseAuth.instance.currentUser?.uid;

              await EventController.updateInFirebase(userId!, event);

              setState(() {
                int index = events.indexWhere((e) => e.id == event.id);
                if (index != -1) {
                  events[index] = event;
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


  InputDecoration textFieldsDecoration(String text) {
    return InputDecoration(
      labelText: '$text',
      labelStyle: TextStyle(
        color: appColors['primary'],
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.black,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          color: Color(0xFFF41F4E),
          width: 2.0,
        ),
      ),
    );
  }

  Future<void> deleteEvent(event_model.Event event) async {
    final isAllowed = await checkIfPledgedOrPurchased(event.id);
    if (isAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You cannot delete this event because it contains pledged or purchased gifts',
            style: TextStyle(fontSize: 18),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'lxgw', color: appColors['primary']),),
        content: Text('Are you sure you want to delete this event?',
          style: TextStyle(fontSize: 18, fontFamily: 'lxgw'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: appColors['primary']),),
          ),
          ElevatedButton(
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
      ),
    );

    if (confirmation == true) {
      await EventController.deleteFromFirebase(userId!, event.id);

      setState(() {
        events.removeWhere((e) => e.id == event.id);
      });
    }
  }

  void sortEvents(String criterion) {
    setState(() {
      selectedSortOption = criterion;
      events.sort((a, b) {
        switch (criterion) {
          case 'Name':
            return a.name.compareTo(b.name);
          case 'Category':
            return a.category.index.compareTo(b.category.index);
          case 'Status':
            return a.status.index.compareTo(b.status.index);
          default:
            return 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createSubPageAppBar('My Events'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: appColors['primary'],))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              style: TextStyle(
                color: appColors['primary'],
                fontSize: 20,
              ),
              underline: Container(
                height: 1,
                color: appColors['primary'],
              ),
              isExpanded: true,
              value: selectedSortOption,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  sortEvents(newValue);
                }
              },
              items: sortOptions.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text('Sort by $option'),
                  ),
                );
              }).toList(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: appColors['primary'],
              ),
              iconSize: 40,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
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
                            builder: (context) => MyEventGiftsListPage(eventId: events[index].id),
                          ),
                        );
                      },
                      title: Text(
                        event.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: appColors['primary'],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category: ${event.category.name}',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            'Status: ${event.status.name}',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            'Date: ${event.date.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            'Location: ${event.location}',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (String result) {
                          if (result == 'Edit') {
                            editEvent(event);
                          } else if (result == 'Delete') {
                            deleteEvent(event);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'Edit',
                            child: Text('Edit', style: TextStyle(fontFamily: 'lxgw', fontWeight: FontWeight.bold, color: appColors['primary'], fontSize: 20),),
                          ),
                          PopupMenuItem<String>(
                            value: 'Delete',
                            child: Text('Delete', style: TextStyle(fontFamily: 'lxgw', fontWeight: FontWeight.bold, color: appColors['primary'], fontSize: 20),),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventPage(),
                  ),
                );
              },
              icon: Icon(Icons.add),
              label: Text(
                'Create New Event',
                style: TextStyle(fontSize: 18),
              ),
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
          ],
        ),
      ),
    );
  }
}