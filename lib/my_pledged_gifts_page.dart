import 'package:flutter/material.dart';
import 'common_widgets.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {

  List<Map<String, String>> pledgedGifts = [
    {
      "giftName": "Smartwatch",
      "friendName": "Kiara",
      "dueDate": "2024-11-01",
      "status": "Pending",
    },
    {
      "giftName": "Wireless Headphones",
      "friendName": "Bob",
      "dueDate": "2024-11-05",
      "status": "Pending",
    },
    {
      "giftName": "Gift Card",
      "friendName": "Marc",
      "dueDate": "2024-11-10",
      "status": "Completed",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Pledged Gifts'),
        backgroundColor: appColors['primary'],
      ),
      body: ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index];
          final isPending = gift["status"] == "Pending";

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
                  gift["giftName"]!,
                  style: TextStyle(
                    color: appColors['primary'],
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pledged to: ${gift["friendName"]!}',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text('Due Date: ${gift["dueDate"]!}',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                trailing: isPending
                    ? IconButton(
                  icon: Icon(Icons.edit, color: appColors['primary']),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Modify ${gift["giftName"]} pledge')),
                    );
                  },
                )
                    : Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
          );
        },
      ),
    );
  }
}