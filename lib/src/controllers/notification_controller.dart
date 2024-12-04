import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core.dart';

class NotificationController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = new ScrollController();
  var showLoader = false.obs;
  var showMoreLoading = false.obs;
  int page = 1;
  bool showLoadMore = true;
  NotificationController() {
    scrollController = new ScrollController();
  }
  MainService mainService = Get.find();
  AuthService authService = Get.find();
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getNotificationSettings() async {
    showLoader.value = true;
    EasyLoading.show(status: "Loading".tr + "...");
    showLoader.refresh();
    var rs = await CommonHelper.sendRequestToServer(endPoint: 'user-notification-setting', method: "post", requestData: {"data_var": "data"});
    showLoader.value = false;
    EasyLoading.dismiss();
    showLoader.refresh();
    if (rs.statusCode == 200) {
      var jsonData = json.decode(rs.body);
      print("jsonData ${rs.body}");
      if (jsonData['status'] && jsonData['data'] != null) {
        mainService.notificationSettings.value = NotificationSettingsModel.fromJSON(jsonData['data']);
        mainService.notificationSettings.refresh();
      } else {}
    } else {}
  }

  Future notificationsList(page) async {
    if (page == 1) {
      EasyLoading.show(status: "Loading".tr + "...");
      showLoader.value = true;
      showLoader.refresh();
    } else {
      showMoreLoading.value = true;
      showMoreLoading.refresh();
    }
    if (page == 1) {
      scrollController = new ScrollController();
    }
    try {
      var response = await CommonHelper.sendRequestToServer(
          endPoint: 'notifications-list',
          requestData: {
            'page': page.toString(),
          },
          method: "post");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          if (page > 1) {
            mainService.notificationsData.value.notifications.addAll(NotificationModel.fromJSON(json.decode(response.body)['data']).notifications);
          } else {
            authService.notificationsCount.value = 0;
            authService.notificationsCount.refresh();
            mainService.notificationsData.value = NotificationModel.fromJSON(json.decode(response.body)['data']);
          }

          if (page == 1) {
            EasyLoading.dismiss();
            showLoader.value = false;
            showLoader.refresh();
          } else {
            showMoreLoading.value = false;
            showMoreLoading.refresh();
          }
          if (mainService.notificationsData.value.notifications.length == mainService.notificationsData.value.total) {
            showLoadMore = false;
          }
          scrollController.addListener(() {
            if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
              if (mainService.notificationsData.value.notifications.length != mainService.notificationsData.value.total && showLoadMore) {
                page = page + 1;
                notificationsList(page);
              }
            }
          });
        }
      }
    } catch (e) {}
  }

  updateNotificationSettings(NotificationSettingsModel data) async {
    var response = await CommonHelper.sendRequestToServer(
        endPoint: 'update-notification-setting',
        requestData: {
          "follow": data.follow == true ? 1 : 0,
          "like": data.like == true ? 1 : 0,
          "comment": data.comment == true ? 1 : 0,
        },
        method: "post");

    print(response.body);
  }
}
