import 'package:flutter/material.dart';
import 'package:eh/views/sign/sign_in.dart';

import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(), // 바구니 생성!
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: SignInPage(),
    );
  }
}
