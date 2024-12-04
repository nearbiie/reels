import 'package:get/get.dart';

import '../core.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainService(), permanent: true);
    Get.put(UserService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(DashboardService(), permanent: true);
    Get.put(DashboardService(), permanent: true);
    Get.put(ChatService(), permanent: true);
    Get.put(PostService(), permanent: true);
    Get.put(SearchService(), permanent: true);
    Get.put(VideoRecorderService(), permanent: true);
    Get.put(SoundService(), permanent: true);
    Get.put(DashboardController(), permanent: true);
    Get.put(PostController(), permanent: true);
    Get.put(NotificationController(), permanent: true);
    Get.put(SearchViewController(), permanent: true);
    Get.put(ChatController(), permanent: true);
    Get.put(SplashScreenController());
    Get.put<PostController>(PostController());
    Get.put(UserController(), permanent: true);
    Get.put(UserProfileController(), permanent: true);
    // Get.put<MainController>(MainController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
    // Get.put(SoundController(), permanent: true);
    Get.put(VideoRecorderController(), permanent: true);
    Get.put(FollowingService(), permanent: true);
    Get.put(FollowingController(), permanent: true);
    // Get.put(NotificationApi(), permanent: true);
    // Get.put(NotificationController(), permanent: true);
    Get.put(AuthService(), permanent: true);
  }
}
