import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core.dart';

class NotificationsView extends StatefulWidget {
  final int type;
  final int userId;
  NotificationsView({Key? key, this.type = 0, this.userId = 0}) : super(key: key);

  @override
  _NotificationsViewState createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  NotificationController notificationController = Get.find();
  MainService mainService = Get.find();
  DashboardService dashboardService = Get.find();
  DashboardController dashboardController = Get.find();

  @override
  void initState() {
    notificationController.notificationsList(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Get.theme.primaryColor, statusBarIconBrightness: Brightness.light),
    );
    return WillPopScope(
      onWillPop: () async {
        dashboardService.showFollowingPage.value = false;
        dashboardService.showFollowingPage.refresh();

        return Future.value(true);
      },
      child: Obx(() {
        return Scaffold(
          backgroundColor: Get.theme.primaryColor,
          appBar: AppBar(
            backgroundColor: Get.theme.primaryColor,
            // leading: InkWell(
            //   onTap: () {
            //     Get.back();
            //   },
            //   child: Icon(
            //     Icons.arrow_back,
            //     color: Get.theme.iconTheme.color,
            //   ),
            // ),
            title: "Notifications".text.uppercase.bold.size(18).color(Get.theme.indicatorColor).make(),
            centerTitle: true,
          ),
          body: SafeArea(
            child: !notificationController.showLoader.value
                ? Obx(() {
                    return SingleChildScrollView(
                      controller: notificationController.scrollController,
                      child: Container(
                        width: Get.width,
                        color: Get.theme.primaryColor,
                        child: mainService.notificationsData.value.notifications.length > 0
                            ? ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: mainService.notificationsData.value.notifications.length,
                                itemBuilder: (context, index) {
                                  final item = mainService.notificationsData.value.notifications.elementAt(index);
                                  return ListTile(
                                    onTap: () {
                                      if (item.type == "L" || item.type == "C") {
                                        mainService.userVideoObj.value.videoId = item.videoId;
                                        mainService.userVideoObj.refresh();
                                        dashboardController.getVideos();
                                        Get.offNamed('/home');
                                        if (item.type == "C") {
                                          Timer(Duration(seconds: 2), () {
                                            dashboardController.hideBottomBar.value = true;
                                            dashboardController.hideBottomBar.refresh();
                                            dashboardController.videoIndex = 0;
                                            dashboardController.showBannerAd.value = false;
                                            dashboardController.showBannerAd.refresh();
                                            dashboardController.pc.open();
                                            Video videoObj = new Video();
                                            videoObj.videoId = item.videoId;
                                            dashboardController.getComments(videoObj).whenComplete(() {
                                              dashboardService.commentsLoaded.value = true;
                                              dashboardService.commentsLoaded.refresh();
                                            });
                                          });
                                        }
                                      } else if (item.type == "F") {
                                        UserController userCon = Get.find();
                                        userCon.openUserProfile(item.userId);
                                      }
                                    },
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                                    dense: true,
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100),
                                        boxShadow: [
                                          BoxShadow(color: Theme.of(context).primaryColor, spreadRadius: 2),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: item.photo != ''
                                            ? CachedNetworkImage(
                                                imageUrl: item.photo,
                                                placeholder: (context, url) => CommonHelper.showLoaderSpinner(mainService.setting.value.buttonColor!),
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                'assets/images/default-user.png',
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    title: Text(
                                      item.msg,
                                      style: TextStyle(
                                        color: Get.theme.indicatorColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                    subtitle: Text(
                                      item.sentOn,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Get.theme.indicatorColor.withOpacity(0.7),
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Get.theme.primaryColor,
                                height: Get.height,
                                width: Get.width,
                                child: Center(
                                  child: Text(
                                    "There is no notification yet!",
                                    style: TextStyle(
                                      color: Get.theme.indicatorColor,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    );
                  })
                : SizedBox(
                    height: 0,
                  ),
          ),
        );
      }),
    );
  }
}
