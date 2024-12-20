import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/views/home.dart';
import 'package:hedieaty/views/login_page.dart';

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await NotificationService().initNotifications();
  });

  group('Friend Adding Test', () {
    testWidgets('User can log in and then add a friend', (WidgetTester tester) async {
      final email = 't@test.com';
      final password = 't123456';

      final existingFriendName = 'Nyla';
      final existingFriendEmail = 't@example.com';

      // building the app widget
      await tester.pumpWidget(HedieatyApp());

      // make sure the app is loaded and starts on the login page
      expect(find.byType(LoginPage), findsOneWidget);

      // fill the login form with data for a registered user
      await tester.enterText(find.byType(TextFormField).at(0), email);
      await tester.enterText(find.byType(TextFormField).at(1), password);

      // click on the login button
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // making sure that the user is logged in
      User? currentUser = FirebaseAuth.instance.currentUser;
      expect(currentUser, isNotNull);
      expect(currentUser!.email, email);

      // after the user is logged in, making sure that the home page is displayed
      expect(find.byType(HomePage), findsOneWidget);

      // start adding a friend
      // click on the button to add a friend
      await tester.tap(find.byIcon(Icons.person_add));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // making sure the add friend dialog displayed to the user
      expect(find.text('Add Friend'), findsOneWidget);

      await Future.delayed(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // make sure an existing registered user is displayed and available for the user to add automatically
      expect(find.text('$existingFriendName'), findsOneWidget);

      // now trying to add a friend manually
      // click on the Add Manually button -available in the dialog-
      await tester.tap(find.text('Add Manually'));
      await tester.pumpAndSettle();

      // enter the friend email in the dialog
      await tester.enterText(find.byType(TextField).at(1), existingFriendEmail);
      await tester.tap(find.text('Add')); // then click on add
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // make sure the friend is added manually and is displayed to the user in the home page -and no scaffold bar saying that the user was not found-
      expect(find.text(existingFriendEmail), findsOneWidget);
      expect(find.text('No User With This Email Was Found. Try Another Email'), findsNothing);

    });
  });
}