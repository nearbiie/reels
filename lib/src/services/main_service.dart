import 'package:get/get.dart';

import '../core.dart';

class MainService extends GetxService {
  var setting = Setting().obs;
  var userVideoObj = UserVideoArgs(videoId: 0, userId: 0, name: "", searchType: '').obs;

  var adsData = <String, dynamic>{
    'android_app_id': '',
    'ios_app_id': '',
    'android_banner_app_id': '',
    'ios_banner_app_id': '',
    'android_interstitial_app_id': '',
    'ios_interstitial_app_id': '',
    'android_video_app_id': '',
    'ios_video_app_id': '',
    'video_show_on': '',
  }.obs;
  var isInternetWorking = true.obs;
  var isOnHomePage = true.obs;
  var isOnNoInternetPage = false.obs;
  var isOnRecordingPage = false.obs;
  var firstTimeLoad = true.obs;

  String rtDescription = "";

  var rtBlocked = false.obs;
  var notificationSettings = NotificationSettingsModel().obs;
  var notificationsData = NotificationModel().obs;
  var loginPageData = LoginScreenData().obs;

  @override
  void onInit() async {
    super.onInit();
  }
}
