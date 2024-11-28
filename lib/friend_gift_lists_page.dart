import 'package:flutter/material.dart';
import 'package:hedieaty/common_widgets.dart';

class FriendsGiftListPage extends StatefulWidget {
  @override
  _FriendsGiftListPageState createState() => _FriendsGiftListPageState();
}

class _FriendsGiftListPageState extends State<FriendsGiftListPage> {
  final String friendName = "Kiara";
  final String eventName = "Birthday Party";

  List<Map<String, dynamic>> gifts = [
    {
      "name": "Smartwatch",
      "description": "A stylish smartwatch to keep track of your health.",
      "isPledged": false,
    },
    {
      "name": "Wireless Headphones",
      "description": "Noise-cancelling wireless headphones for the music lover.",
      "isPledged": false,
    },
    {
      "name": "Gift Card",
      "description": "A gift card for your favorite store.",
      "isPledged": false,
    },
  ];

  void pledgeGift(int index) {
    setState(() {
      gifts[index]["isPledged"] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${gifts[index]["name"]} pledged!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createSubPageAppBar('$friendName\'s $eventName Gifts'),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
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
                        gift["name"]!,
                        style: TextStyle(
                          color: appColors['primary'],
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text(
                        gift["description"]!,
                        style: TextStyle(fontSize: 16),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          gift["isPledged"] ? Icons.check_box : Icons.add_box_rounded,
                          color: appColors['primary'],
                        ),
                        onPressed: gift["isPledged"]
                            ? null
                            : () => pledgeGift(index),
                      ),
                      tileColor: gift["isPledged"] ? appColors['pledged'] : null,
                      onTap: () {

                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
