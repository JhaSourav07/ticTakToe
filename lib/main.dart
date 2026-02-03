import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ticktaktoe/views/game_view.dart';
import 'firebase_options.dart'; // <--- 1. IMPORT THIS

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tic Tac Toe Party',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}