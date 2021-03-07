import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

extension ScreenSizeUtils on WidgetTester {
  void configureScreenSize(Size screenSize) {
    binding.window.devicePixelRatioTestValue = 1.0;
    binding.window.physicalSizeTestValue = screenSize;
  }
}

void expectWidgetFromKeyToHaveScreenWidth(
    Key key, WidgetTester tester, double screenWidth) {
  final widgetFinder = find.byKey(key);
  final widgetSize = tester.getSize(widgetFinder);
  expect(widgetSize.width, screenWidth);
}

void expectWidgetFromKeyToHaveHalfOfTheScreenWidth(
  Key key,
  WidgetTester tester,
  double screenWidth,
) {
  final widgetFinder = find.byKey(key);
  final widgetSize = tester.getSize(widgetFinder);
  expect(widgetSize.width, screenWidth / 2);
}
