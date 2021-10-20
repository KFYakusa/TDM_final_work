import 'dart:async';

import 'package:flutter/material.dart';

import 'LoginPage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Timer(Duration(seconds: 5), (){
      Navigator.pushReplacement( context, MaterialPageRoute(builder: (_) => LoginPage() )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white70,
        padding: EdgeInsets.all(60),
        child: Center(
          child: Image.asset("assets/imgs/logo.png"),
        ),
      ),
    );
  }
}
