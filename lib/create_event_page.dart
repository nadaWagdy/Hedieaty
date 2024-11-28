import 'package:flutter/material.dart';
import 'common_widgets.dart';

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _eventDescriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _category = 'Birthday';
  String _status = 'Upcoming';

  List<String> _categories = ['Birthday', 'Wedding', 'Graduation', 'Holiday'];
  List<String> _statuses = ['Upcoming', 'Current', 'Past'];

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
                DropdownButtonFormField<String>(
                  value: _status,
                  style: TextStyle(
                      color: appColors['primary'],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  decoration: TextFieldDecoration.searchInputDecoration('Status'),
                  items: _statuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                ),
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
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event saved: ${_eventNameController.text}'),
      ),
    );
    _eventNameController.clear();
    _eventDescriptionController.clear();
    setState(() {
      _category = 'Birthday';
      _status = 'Upcoming';
      _selectedDate = DateTime.now();
    });
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }
}
