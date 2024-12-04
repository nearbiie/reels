import 'package:bouncy_widget/bouncy_widget.dart';
import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core.dart';

class AiDescriptionPromptWidget extends StatelessWidget {
  final VideoRecorderController videoRecorderController = Get.find();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          color: Colors.black,
          padding: EdgeInsets.all(16.0),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AI GIF Image
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          image: DecorationImage(
                            image: AssetImage(
                              "assets/icons/ai.gif",
                            ), // Replace 'assets/ai.gif' with your actual image path
                            fit: BoxFit.contain,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Icon(
                          Icons.close,
                          size: 30,
                          weight: 100,
                          color: Colors.white,
                        ).onInkTap(() {
                          Get.back();
                        }),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                // Description Text Field
                Expanded(
                  flex: 1,
                  child: TextField(
                    maxLines: 5,
                    style: TextStyle(color: Colors.grey),
                    decoration: InputDecoration(
                      hintText: 'What Kind of description you want AI to write for you. You can also ask for popular hashtags for your video.'.tr,
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    onChanged: (val) {
                      videoRecorderController.aiPrompt = val;
                    },
                  ),
                ),
                SizedBox(height: 8.0),
                Bouncy(
                  duration: Duration(milliseconds: 2000),
                  lift: 15,
                  ratio: 0.25,
                  pause: 0.5,
                  child: ElTooltip(
                    content: Text('Generate Description'),
                    child: ElevatedButton(
                      onPressed: () async {
                        await videoRecorderController.generateAIDescription();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(8),
                      ),
                      child: Image.asset(
                        "assets/icons/artificial-intelligence.png",
                        height: 45,
                      ),
                    ).objectCenterRight(),
                  ),
                ),
                SizedBox(height: 30.0),
                // Hashtags Text Field
              ],
            ),
          ),
        ),
      ),
    );
  }
}
