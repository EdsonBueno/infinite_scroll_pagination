import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

const screenSize = Size(200, 500);

extension ScreenSizeUtils on WidgetTester {
  void applyPreferredTestScreenSize() {
    binding.window.devicePixelRatioTestValue = 1.0;
    binding.window.physicalSizeTestValue = screenSize;
  }
}

void expectWidgetToHaveScreenWidth(
  Key widgetKey,
  WidgetTester tester,
) {
  final widgetFinder = find.byKey(widgetKey);
  final widgetSize = tester.getSize(widgetFinder);
  expect(
    widgetSize.width,
    screenSize.width,
  );
}

void expectWidgetToHaveHalfOfTheScreenWidth(
  Key widgetKey,
  WidgetTester tester,
) {
  final widgetFinder = find.byKey(widgetKey);
  final widgetSize = tester.getSize(widgetFinder);
  expect(widgetSize.width, screenSize.width / 2);
}
