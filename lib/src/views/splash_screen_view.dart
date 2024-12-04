import 'dart:async';

import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

import '../core.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  String dataShared = "No Data";
  SplashScreenController splashScreenController = Get.find();
  MainService mainService = Get.find();
  late BuildContext context;
  DateTime currentBackPressTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/loading-video.mp4');

    _controller.setLooping(false);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: () {
          DateTime now = DateTime.now();
          // Get.back();
          if (now.difference(currentBackPressTime) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            Fluttertoast.showToast(msg: "Tap again to exit an app.");
            return Future.value(false);
          }
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          return Future.value(true);
        },
        child: Container(
          height: Get.height,
          width: Get.width,
          child: FlutterSplashScreen(
            useImmersiveMode: true,
            // duration: const Duration(milliseconds: 2000),
            backgroundColor: Colors.black,
            asyncNavigationCallback: () async {
              await splashScreenController.initializing();
            },
            splashScreenBody: Center(
              child: Lottie.asset(
                "assets/animations/loading-lottie.json",
                repeat: true,
              ),
            ), /*FlutterSplashScreen.gif(
              useImmersiveMode: true,
              gifPath: 'assets/images/loading.gif',
              gifWidth: Get.width * 0.8,
              gifHeight: Get.width * 0.8,
              asyncNavigationCallback: () async {
                await splashScreenController.initializing();
              },
            ),*/
          ),
        ),
      ),
    );
  }
}
