import 'package:infinite_example/common/touch_physics.dart';
import 'package:infinite_example/home_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Infinite Scroll Pagination Sample',
        scrollBehavior: const TouchBehaviour(),
        theme: ThemeData.from(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.greenAccent,
            brightness:
                WidgetsBinding.instance.platformDispatcher.platformBrightness,
          ),
        ),
        home: const Home(),
      );
}
