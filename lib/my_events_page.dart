import 'package:flutter/material.dart';
import 'common_widgets.dart';

class MyEventsPage extends StatefulWidget {
  @override
  _MyEventsPageState createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  String selectedSortOption = 'Name';
  List<String> sortOptions = ['Name', 'Category', 'Status'];

  List<Map<String, String>> events = [
    {
      'name': 'Birthday Party',
      'category': 'Social',
      'status': 'Upcoming',
      'date': '2024-11-05',
      'location': 'New York'
    },
    {
      'name': 'Conference',
      'category': 'Work',
      'status': 'Current',
      'date': '2024-10-30',
      'location': 'San Francisco'
    },
    {
      'name': 'Wedding',
      'category': 'Family',
      'status': 'Past',
      'date': '2023-12-25',
      'location': 'Los Angeles'
    },
    {
      'name': 'Birthday Party',
      'category': 'Social',
      'status': 'Upcoming',
      'date': '2024-11-05',
      'location': 'New York'
    },
    {
      'name': 'Conference',
      'category': 'Work',
      'status': 'Current',
      'date': '2024-10-30',
      'location': 'San Francisco'
    },
    {
      'name': 'Wedding',
      'category': 'Family',
      'status': 'Past',
      'date': '2023-12-25',
      'location': 'Los Angeles'
    },
  ];

  void sortEvents(String criterion) {
    setState(() {
      selectedSortOption = criterion;
      events.sort((a, b) => a[criterion.toLowerCase()]!.compareTo(b[criterion.toLowerCase()]!));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createSubPageAppBar('My Events'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                  )
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
                      title: Text(event['name'] ?? 'Unnamed Event',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: appColors['primary']
                      ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category: ${event['category']}',
                          style: TextStyle(
                            fontSize: 18
                          ),
                          ),
                          Text('Status: ${event['status']}',
                            style: TextStyle(
                                fontSize: 18
                            ),
                          ),
                          Text('Date: ${event['date']}',
                            style: TextStyle(
                                fontSize: 18
                            ),
                          ),
                          Text('Location: ${event['location']}',
                            style: TextStyle(
                                fontSize: 18
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (String result) {
                          if (result == 'Edit') {

                          } else if (result == 'Delete') {
                            setState(() {
                              events.removeAt(index);
                            });
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'Edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem<String>(
                            value: 'Delete',
                            child: Text('Delete'),
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

              },
              icon: Icon(Icons.add),
              label: Text('Add New Event',
                style: TextStyle(
                  fontSize: 18
                ),
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
