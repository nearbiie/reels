import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core.dart';

class NotificationSetting extends StatefulWidget {
  NotificationSetting({Key? key}) : super(key: key);
  @override
  _NotificationSettingState createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  NotificationController notificationController = NotificationController();
  bool isEdit = false;
  MainService mainService = Get.find();
  @override
  void initState() {
    notificationController.getNotificationSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.light),
    );
    return WillPopScope(
      onWillPop: () async {
        notificationController.updateNotificationSettings(mainService.notificationSettings.value);
        return Future.value(true);
      },
      child: Scaffold(
        key: notificationController.scaffoldKey,
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: AppBar(
            iconTheme: IconThemeData(
              color: Get.theme.iconTheme.color, //change your color here
            ),
            backgroundColor: Get.theme.primaryColor,
            title: Text(
              "Notifications Setting",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
                color: Get.theme.indicatorColor,
              ),
            ),
            centerTitle: true,
          ),
        ),
        body: SafeArea(
          child: Obx(() {
            if (!notificationController.showLoader.value) {
              return Container(
                color: Get.theme.primaryColor,
                height: Get.height,
                width: Get.width,
                child: SingleChildScrollView(
                  controller: notificationController.scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              color: Get.theme.shadowColor.withOpacity(0.3),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        "Push Notification".text.textStyle(Theme.of(context).textTheme.headlineMedium!.copyWith(color: Get.theme.indicatorColor)).make().pOnly(bottom: 5),
                                        "Turn on all mobile notifications or select which to receive"
                                            .text
                                            .textStyle(Theme.of(context).textTheme.headlineSmall!.copyWith(color: Get.theme.indicatorColor))
                                            .make(),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Transform.scale(
                                      scale: 0.6,
                                      child: CupertinoSwitch(
                                        activeColor: Get.theme.highlightColor,
                                        value: (mainService.notificationSettings.value.follow && mainService.notificationSettings.value.like && mainService.notificationSettings.value.comment)
                                            ? true
                                            : false,
                                        onChanged: (value) {
                                          if (value) {
                                            mainService.notificationSettings.value.follow = true;
                                            mainService.notificationSettings.value.like = true;
                                            mainService.notificationSettings.value.comment = true;
                                            mainService.notificationSettings.refresh();
                                          } else {
                                            mainService.notificationSettings.value.follow = false;
                                            mainService.notificationSettings.value.like = false;
                                            mainService.notificationSettings.value.comment = false;
                                            mainService.notificationSettings.refresh();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              color: Get.theme.primaryColor,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Row(
                                      children: [
                                        "User follow you".text.color(Get.theme.indicatorColor).make(),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Transform.scale(
                                      scale: 0.6,
                                      child: CupertinoSwitch(
                                        activeColor: Get.theme.highlightColor,
                                        value: mainService.notificationSettings.value.follow,
                                        onChanged: (value) {
                                          mainService.notificationSettings.value.follow = !mainService.notificationSettings.value.follow;
                                          mainService.notificationSettings.refresh();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 1,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              color: Get.theme.primaryColor,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Row(
                                      children: [
                                        "Like on your video".text.color(Get.theme.indicatorColor).make(),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Transform.scale(
                                      scale: 0.6,
                                      child: CupertinoSwitch(
                                        activeColor: Get.theme.highlightColor,
                                        value: mainService.notificationSettings.value.like,
                                        onChanged: (value) {
                                          mainService.notificationSettings.value.like = !mainService.notificationSettings.value.like;
                                          mainService.notificationSettings.refresh();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 1,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              color: Get.theme.primaryColor,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Row(
                                      children: [
                                        "Comment on your video.".text.color(Get.theme.indicatorColor).make(),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Transform.scale(
                                      scale: 0.6,
                                      child: CupertinoSwitch(
                                        activeColor: Get.theme.highlightColor,
                                        value: mainService.notificationSettings.value.comment,
                                        onChanged: (value) {
                                          mainService.notificationSettings.value.comment = !mainService.notificationSettings.value.comment;
                                          mainService.notificationSettings.refresh();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Container(
                color: Get.theme.primaryColor,
                height: Get.height,
                width: Get.width,
                child: Center(
                  child: CommonHelper.showLoaderSpinner(Get.theme.iconTheme.color!),
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}
