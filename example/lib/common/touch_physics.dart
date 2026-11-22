import 'dart:ui';

import 'package:material_ui/material_ui.dart';

/// Allows any device to scroll via touch.
class TouchBehaviour extends ScrollBehavior {
  const TouchBehaviour();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
