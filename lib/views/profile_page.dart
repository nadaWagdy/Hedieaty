import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/user.dart';
import 'common_widgets.dart';
import 'my_events_page.dart';
import 'my_pledged_gifts_page.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  bool _notificationsEnabled = true;
  final DatabaseService _dbService = DatabaseService();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;

    try {
      User? user = await User.fetchFromFirebase(userId!);

      if (user == null) {
        final drafts = await User.getDrafts();
        user = drafts.firstWhere((u) => u.id == userId);
      }

      if (user != null) {
        setState(() {
          _user = user;
          _notificationsEnabled = user!.notificationPreferences;
        });
      }
    } catch (error) {
      print("Error fetching user data: $error");
    }
  }

  Future<void> _updateProfileImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _user?.profilePicture = pickedImage.path;
      });
      final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      await User.updateProfilePicture(userId!, pickedImage.path);
      await _dbService.updateUser(_user!);
    }
  }

  Future<void> _updateName(String newName) async {
    setState(() {
      _user?.name = newName;
    });

    final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    await User.updateUserName(userId!, newName);
    await _dbService.updateUser(_user!);
  }

  Future<void> _editProfile() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profile',
            style: TextStyle(
                color: appColors['primary'],
                fontFamily: 'lxgw',
                fontWeight: FontWeight.bold,
                fontSize: 26),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Change Profile Picture',
                  style: TextStyle(
                      fontFamily: 'lxgw',
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _updateProfileImage();
                },
              ),
              ListTile(
                title: Text('Change User Name',
                  style: TextStyle(
                      fontFamily: 'lxgw',
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  String? newName = await _showEditNameDialog(context);
                  if (newName != null && newName.isNotEmpty) {
                    _updateName(newName);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _showEditNameDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController(text: _user?.name);

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Name',
            style: TextStyle(
                color: appColors['primary'],
                fontFamily: 'lxgw',
                fontWeight: FontWeight.bold,
                fontSize: 26),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Enter new name',
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
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: Text('Save', style: TextStyle(fontSize: 18),),
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors['primary'],
                foregroundColor: appColors['buttonText'],
                shadowColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding:
                EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel',  style: TextStyle(color: appColors['primary'], fontSize: 18)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateNotificationPreference(bool value) async {
    if (_user == null) return;

    setState(() {
      _notificationsEnabled = value;
    });

    try {
      final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      _user!.notificationPreferences = value;
      await User.updateNotificationPreferences(userId!, value);

      await _dbService.updateUser(_user!);
    } catch (error) {
      print("Error updating notification preferences: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: createSubPageAppBar('Profile'),
        body: Center(child: CircularProgressIndicator(color: appColors['primary'],)),
      );
    }

    return Scaffold(
      appBar: createSubPageAppBar('Profile'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: getImageProvider(_user!.profilePicture),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user!.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: appColors['buttonText'],
                        ),
                      ),
                      Text(
                        _user!.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: appColors['buttonText'],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: appColors['buttonText'],
                  ),
                  onPressed: _editProfile,
                ),
              ],
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                "Enable Notifications",
                style: TextStyle(
                  color: appColors['buttonText'],
                  fontSize: 20,
                ),
              ),
              activeColor: appColors['primary'],
              inactiveThumbColor: appColors['buttonText'],
              inactiveTrackColor: appColors['unselected'],
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                _updateNotificationPreference(value);
              },
            ),
            Divider(thickness: 2),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Created Events",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: appColors['buttonText']
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyEventsPage(),
                      ),
                    );
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
                  child: Text('Show all events'),
                ),
              ],
            ),
            SizedBox(height: 40),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyPledgedGiftsPage(),
                    ),
                  );
                },
                child: Text(
                  "View My Pledged Gifts",
                  style: TextStyle(
                    color: appColors['primary'],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
