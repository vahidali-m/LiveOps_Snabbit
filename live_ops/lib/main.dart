import 'package:flutter/material.dart';
import 'package:live_ops/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'provider/job_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
  create: (_) => JobProvider()..loadData(),
  child: MyApp(),
)
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
