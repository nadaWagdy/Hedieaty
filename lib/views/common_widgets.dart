import 'package:flutter/material.dart';
import '../models/enums.dart';

final Map<String, Color> appColors = {
  'primary': Color(0xFFF41F4E),
  'secondary': Color(0xFF0B192C),
  'background': Color(0xff000000),
  'buttonText': Color(0xFFffffff),
  'listCard' : Color(0xffffffff),
  'eventAlert' : Color(0xFFF41F4E),
  'unselected' : Color(0xff9388A2),
  'pledged' : Color(0xffdfd8ea)
};

class TextFieldDecoration {

  static InputDecoration searchInputDecoration(String displayText) {
    return InputDecoration(
      labelText: '$displayText',
      labelStyle: TextStyle(
        color: appColors['buttonText'],
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: const Color(0xFFFFFFFF),
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
    );
  }
}

class SearchFieldDecoration {

  static InputDecoration searchInputDecoration(String displayText) {
    return InputDecoration(
      labelText: '$displayText',
      labelStyle: TextStyle(
        color: appColors['buttonText'],
        fontWeight: FontWeight.bold,
      ),
      prefixIcon: Icon(
        Icons.search,
        color: appColors['listCard'],
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: const Color(0xFFFFFFFF),
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
    );
  }
}

AppBar createSubPageAppBar(String text)
{
  return AppBar(
    title: Text('$text',
      style: TextStyle(
          fontFamily: 'lxgw',
          fontSize: 23
      ),
    ),
    backgroundColor: appColors['primary'],
  );
}

Color? getGiftStatusColor(GiftStatus status) {
  switch (status) {
    case GiftStatus.pledged:
    // return appColors['pledged'];
    // return Color(0xfffcb6c5);
      return Colors.tealAccent;
    case GiftStatus.available:
      return appColors['listCard'];
    case GiftStatus.purchased:
      return Colors.amberAccent;
    default:
      return Colors.grey;
  }
}

Color? getGiftStatusTextColor(GiftStatus status) {
  switch (status) {
    case GiftStatus.pledged:
      return Colors.tealAccent;
    case GiftStatus.available:
      return Colors.green;
    case GiftStatus.purchased:
      return Colors.amberAccent;
    default:
      return Colors.grey;
  }
}

InputDecoration textFieldsDecoration(String text) {
  return InputDecoration(
    labelText: '$text',
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
  );
}