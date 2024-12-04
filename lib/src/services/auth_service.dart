import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../core.dart';

class AuthService extends GetxService {
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
    'email',
    "https://www.googleapis.com/auth/userinfo.profile",
  ]);
  var currentUser = new User().obs;
  var notificationsCount = 0.obs;
  var errorString = "".obs;
  var socialUserProfile = User().obs;
  var myProfile = User().obs;
  var userFavVideos = User().obs;
  var socketId = ''.obs;
  var loginPageData = LoginScreenData().obs;

  var resetPasswordEmail = "".obs;

  @override
  void onInit() async {
    super.onInit();
  }
}
