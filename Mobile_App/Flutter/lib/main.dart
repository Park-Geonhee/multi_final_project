import 'package:flutter/material.dart';
import 'package:mulcam_final/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:provider/provider.dart';
import 'package:mulcam_final/screens/home.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // 메인 내부에서 비동기방식 메서드(플러터엔진 초기화가 필요)를 위해 사용
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Store(),
      child: MaterialApp(
        title: 'Dupi',
        theme: theme,
        home: LoginSignupScreen(),
      ),
    );
  }
}

var theme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black87),
    appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.black87,
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
            color: Colors.black87, fontSize: 22, fontWeight: FontWeight.w600),
        actionsIconTheme: IconThemeData(color: Colors.black87)),
    );
