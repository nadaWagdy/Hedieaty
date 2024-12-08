import 'package:flutter/material.dart';
import 'common_widgets.dart';

class CreateGiftListPage extends StatefulWidget {
  @override
  _CreateGiftListPageState createState() => _CreateGiftListPageState();
}

class _CreateGiftListPageState extends State<CreateGiftListPage> {
  String? selectedEvent;
  List<String> events = ['Birthday', 'Wedding', 'Graduation'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createSubPageAppBar('Create Gift List'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              decoration: TextFieldDecoration.searchInputDecoration('Gift List Title'),
              style: TextStyle(color: appColors['buttonText']),
              cursorColor: appColors['buttonText'],
            ),
            SizedBox(height: 20),
            TextFormField(
              maxLines: 3,
              decoration: TextFieldDecoration.searchInputDecoration('Gift List Description'),
              style: TextStyle(color: appColors['buttonText']),
              cursorColor: appColors['buttonText'],
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: TextFieldDecoration.searchInputDecoration('Category'),
              style: TextStyle(
                color: appColors['primary'],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              value: null,
              onChanged: (String? newValue) {},
              items: <String>['Electronics', 'Books', 'Clothing', 'Others'].map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {},
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
            Expanded(
              child: ListView.separated(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Card(
                    color: appColors['listCard'],
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text('Gift $index',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                          )
                      ),
                      subtitle: Text('Category: Books',
                          style: TextStyle(fontSize: 15)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {},
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: ElevatedButton(
                onPressed: () {},
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
              ),
            )
          ],
        ),
      ),
    );
  }
}
