import 'package:flutter/material.dart';
import 'package:chello/screens/welcome_screen.dart';
import 'package:chello/screens/login_screen.dart';
import 'package:chello/screens/registration_screen.dart';
import 'package:chello/screens/chat_screen.dart';

void main() => runApp(FlashChat());

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //home: WelcomeScreen(),
      initialRoute: WelcomeScreen.id,
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context)=>RegistrationScreen(),
        WelcomeScreen.id:(context)=>WelcomeScreen(),
        ChatScreen.id: (context)=>ChatScreen(),
      }
    );
  }
}
