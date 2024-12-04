import 'package:get/get.dart';

import '../core.dart';

class FollowingService extends GetxService {
  var usersData = FollowingModel().obs;
  var friendsData = FollowingModel().obs;

  @override
  void onInit() async {
    super.onInit();
  }
}
