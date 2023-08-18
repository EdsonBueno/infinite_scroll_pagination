import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

const screenSize = Size(
  200,
  500,
);

extension ScreenSizeUtils on WidgetTester {
  void applyPreferredTestScreenSize() {
    view.devicePixelRatio = 1.0;
    view.physicalSize = screenSize;
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
