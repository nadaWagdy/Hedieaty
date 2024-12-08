import 'package:flutter/material.dart';
import 'common_widgets.dart';

class MyEventGiftsListPage extends StatelessWidget {
  final String eventName;
  final List<String> gifts;

  MyEventGiftsListPage({required this.eventName, required this.gifts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createSubPageAppBar(eventName),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gifts for $eventName",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: appColors['buttonText'],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: gifts.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: appColors['listCard'],
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        gifts[index],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
}
