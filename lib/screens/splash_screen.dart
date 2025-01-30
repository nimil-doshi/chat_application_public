import 'package:chat_application/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
        WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        // exit full screen
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white, statusBarColor: Colors.white));
        // navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      });
    }); 
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        // home button
        automaticallyImplyLeading: false,
        title: Text('Welcome')
      ),
      //adding image to Splash screen
      body: Stack(children: [
        // image icon
        Positioned(
          top: mq.height*.15, width: mq.width*.50, left: mq.width*.25,
          child: Image.asset('images/icon.png')
        ),
        //button icon
        Positioned(
          bottom: mq.height*.15, width: mq.width,
          child: Text('Made In India.',
          textAlign: TextAlign.center,
           style: TextStyle(fontSize: 16, color: Colors.black),)
        ),
      ],),

    );
  }
}