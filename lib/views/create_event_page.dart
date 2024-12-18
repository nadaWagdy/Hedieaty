import 'package:flutter/material.dart';
import 'common_widgets.dart';
import 'package:hedieaty/models/event.dart' as app_event;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:hedieaty/services/auth.dart';
import 'package:hedieaty/models/enums.dart';

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _eventDescriptionController = TextEditingController();
  TextEditingController _eventLocationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _category = 'personal';
  String _status = 'upcoming';

  List<String> _categories = ['personal', 'birthday', 'wedding', 'graduation', 'other'];

  void _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    firebase_auth.User? user = Auth().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No user logged in.')),
      );
      return;
    }

    if (_selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day)
      _status = EventStatus.current.name;
    else
      _status = EventStatus.upcoming.name;

    final newEvent = app_event.Event(
      name: _eventNameController.text,
      date: _selectedDate,
      location: _eventLocationController.text,
      description: _eventDescriptionController.text,
      status: EventStatus.values.firstWhere((e) => e.name == _status),
      category: EventCategory.values.firstWhere((e) => e.name == _category),
    );

    try {
      await app_event.Event.publishToFirebase(newEvent, user.uid);

      await app_event.Event.saveDraft(newEvent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event saved: ${newEvent.name}')),
      );
      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving event: $e')),
      );
    }
  }

  void _resetForm() {
    _eventNameController.clear();
    _eventDescriptionController.clear();
    _eventLocationController.clear();
    setState(() {
      _category = 'personal';
      _status = 'upcoming';
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createSubPageAppBar('Create Event'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _eventNameController,
                  style: TextStyle(
                      color: appColors['buttonText']
                  ),
                  cursorColor: appColors['buttonText'],
                  decoration: TextFieldDecoration.searchInputDecoration('Event Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _eventDescriptionController,
                  style: TextStyle(
                      color: appColors['buttonText']
                  ),
                  cursorColor: appColors['buttonText'],
                  decoration: TextFieldDecoration.searchInputDecoration('Event Description'),
                  maxLines: 3,
                ),
                TextFormField(
                  controller: _eventLocationController,
                  style: TextStyle(
                      color: appColors['buttonText']
                  ),
                  cursorColor: appColors['buttonText'],
                  decoration: TextFieldDecoration.searchInputDecoration('Event Location'),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                Center(
                child: Text('Event' + ' ' + 'Date:' + ' ' + '${_selectedDate.toLocal()}'.split(' ')[0],
                  style: TextStyle(
                    color: appColors['buttonText'],
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),),
                SizedBox(height: 10,),
                Center(
                  child: ElevatedButton(
                  onPressed: () => _selectDate(context),
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
                  child: Text('Select Date'),
                ),),
                SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _category,
                  style: TextStyle(
                      color: appColors['primary'],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                  ),
                  decoration: TextFieldDecoration.searchInputDecoration('Category'),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _category = value!;
                    });
                  },
                ),
                SizedBox(height: 16),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveEvent();
                    }
                  },
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
                  child: Text('Save Event'),
                ),)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }
}
