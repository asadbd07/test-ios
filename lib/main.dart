import 'package:flutter/material.dart';
import 'screen/login.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'SINGER OTP';
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      title: appTitle,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: const LoginForm(),
      ),
    );
  }
}
