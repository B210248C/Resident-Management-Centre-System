import 'package:flutter/widgets.dart';
import 'package:dcdg/dcdg.dart';

class AppConstant {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double baseWidth = 360.0;
  static double baseHeight = 800.0;

  static double widthScale(BuildContext context) {
    return screenWidth(context) / baseWidth;
  }

  static double heightScale(BuildContext context) {
    return screenHeight(context) / baseHeight;
  }
}
