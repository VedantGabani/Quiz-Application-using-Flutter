import 'package:quiz_application/PreviousResult.dart';
import 'package:quiz_application/mainDashboard.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'LoginPage.dart';
import 'RegistrationPage.dart';
import 'dashboard.dart';
import 'result.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz Application',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        DashBoard.id: (context) => DashBoard(),
        Result.id: (context) => Result(),
        MainDashboard.id: (context) => MainDashboard(),
        PreviousResult.id: (context) => PreviousResult(),
      },
    );
  }
}
