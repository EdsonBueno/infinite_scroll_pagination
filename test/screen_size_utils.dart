import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

extension ScreenSizeUtils on WidgetTester {
  void configureScreenSize(Size screenSize) {
    binding.window.devicePixelRatioTestValue = 1.0;
    binding.window.physicalSizeTestValue = screenSize;
  }
}
