import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../core.dart';

class UserService extends GetxService {
  var blockedUsersData = BlockedModel().obs;
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
    'email',
    "https://www.googleapis.com/auth/userinfo.profile",
  ]);
  var usersData = VideoModel().obs;
  var userProfile = User().obs;
  // var usersProfileData = User().obs;
  var userId = 0.obs;
  var followListType = 1.obs;
  int followListUserId = 0;
  Video currentEditVideo = Video();

  @override
  void onInit() async {
    super.onInit();
  }
}
