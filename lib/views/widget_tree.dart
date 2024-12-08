import 'package:flutter/material.dart';
import 'package:hedieaty/services/auth.dart';
import 'package:hedieaty/views/home.dart';
import 'package:hedieaty/views/login_page.dart';

class WidgetTree extends StatefulWidget{
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();

}

class _WidgetTreeState extends State<WidgetTree>{


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return AppLayout();
          }else {
            return LoginPage();
          }
        }
    );
  }

}