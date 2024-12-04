import 'package:animations/animations.dart';
import 'package:bouncy_widget/bouncy_widget.dart';
import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core.dart';

class VideoDescriptionWidget extends StatelessWidget {
  VideoDescriptionWidget({Key? key}) : super(key: key);
  final VideoRecorderController videoRecorderController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: Get.height / 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(-3, -3),
              ),
            ],
          ),
          child: Obx(
            () => DetectableTextField(
              controller: videoRecorderController.detectableTextVideoDescriptionController.value,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Write your post description here'.tr + "...",
                hintStyle: TextStyle(
                  color: Get.theme.indicatorColor.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
                contentPadding: EdgeInsets.all(10.0),
                border: InputBorder.none,
              ),
              // validator: videoRecorderController.validateDescription,
              onSubmitted: (String? val) {
                videoRecorderController.description.value = val!;
              },
              onChanged: (String val) {
                videoRecorderController.description.value = val;
              },
              style: TextStyle(
                color: Get.theme.indicatorColor,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
        Positioned(
          right: 5,
          bottom: 5,
          child: Bouncy(
            duration: Duration(milliseconds: 2000),
            lift: 15,
            ratio: 0.25,
            pause: 0.5,
            child: OpenContainer(
              transitionType: ContainerTransitionType.fade,
              openBuilder: (BuildContext context, VoidCallback _) {
                return AiDescriptionPromptWidget();
              },
              transitionDuration: Duration(seconds: 2),
              closedElevation: 6.0,
              closedShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              closedColor: Colors.black,
              closedBuilder: (BuildContext context, VoidCallback openContainer) {
                return Image.asset(
                  "assets/icons/ai.gif",
                  height: 30,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
