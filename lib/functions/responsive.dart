import 'package:flutter/cupertino.dart';

class Responsive {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  static double scale(BuildContext context) {
    return isTablet(context) ? 1.5 : 1.0;
  }
}