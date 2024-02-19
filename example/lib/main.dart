import 'package:brewtiful/beer_list_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Infinite Scroll Pagination Sample',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const BeerListScreen(),
      );
}
