import 'dart:ui';

import 'package:flutter/material.dart';

class GillMT {
  static TextStyle normal(double fontSize) {
    return TextStyle(
      fontFamily: 'GillSansMT', fontSize: fontSize
    );
  }

  static TextStyle title(double fontSize) {
    return TextStyle(
      fontFamily: 'GillSansMT', fontSize: fontSize, fontWeight: FontWeight.bold
    );
  }

  static TextStyle light(double fontSize) {
    return TextStyle(
        fontFamily: 'GillSansMT', fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.black54
    );
  }

  static TextStyle lighter(double fontSize) {
    return TextStyle(
        fontFamily: 'GillSansMT', fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.black38
    );
  }

}