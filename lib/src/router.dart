import 'package:get/get.dart';
import 'package:leuke/src/views/dashboard1_view.dart';

import 'core.dart';

class Routes {
  static final route = [
    GetPage(
      name: '/',
      page: () => SplashScreen(),
      binding: MainBinding(),
    ),
    GetPage(
      name: '/home',
      page: () => DashboardView(),
      // binding: MainBinding(),
      // middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/projects',
      page: () => DashboardPage(),
      // binding: MainBinding(),
      // middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/no-internet',
      page: () => InternetPage(),
      // binding: MainBinding(),
      // middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/eula',
      page: () => EulaView(),
      // binding: MainBinding(),
      // middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/login',
      page: () => LoginView(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: '/complete-profile',
      page: () => CompleteProfileView(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: '/register',
      page: () => RegisterView(),
    ),
    GetPage(
      name: '/edit-profile',
      page: () => EditProfileView(),
    ),
    GetPage(
      name: '/verify-profile',
      page: () => VerifyProfileView(),
    ),
    GetPage(
      name: '/blocked-users',
      page: () => BlockedUsers(),
    ),
    GetPage(
      name: '/notification-settings',
      page: () => NotificationSetting(),
    ),
    GetPage(
      name: '/chat-settings',
      page: () => ChatSetting(),
    ),
    GetPage(
      name: '/change-password',
      page: () => ChangePasswordView(),
    ),
    GetPage(
      name: '/verify-otp',
      page: () => VerifyOTPView(),
    ),
    GetPage(
      name: '/reset-forgot-password',
      page: () => ResetForgotPasswordView(),
    ),
    GetPage(
      name: '/chat',
      page: () => ChatView(),
    ),
    GetPage(
      name: '/user-profile',
      page: () => UsersProfileView(),
    ),
    GetPage(
      name: '/forgot-password',
      page: () => ForgotPasswordView(),
    ),
    GetPage(
      name: '/users',
      page: () => UsersView(),
    ),
    GetPage(
      name: '/followers',
      page: () => FollowingView(),
    ),
    GetPage(
      name: '/edit-video',
      page: () => EditVideo(),
    ),
    GetPage(
      name: '/notifications',
      page: () => NotificationsView(),
    ),
    /*GetPage(
      name: '/users',
      page: () => UsersView(),

      binding: SettingsBinding(),
    ),*/
    GetPage(
      name: '/search',
      page: () => SearchPage(),
    ),
    GetPage(
      name: '/hash-tag',
      page: () => HashVideosView(),
    ),
    GetPage(
      name: '/video-recorder',
      page: () => VideoRecorder(),
      /*binding: BindingsBuilder(() {
        Get.put(VideoRecorderController(), permanent: true);
      }),*/
    ),
    GetPage(
      name: '/video-editor',
      // binding: VideoEditorBinding(),
      page: () => VideoEditor(),
    ),
    GetPage(
      name: '/stories-editor',
      // binding: VideoEditorBinding(),
      page: () => StoresEditorView(),
    ),
    GetPage(
      name: '/video-preview',
      // binding: VideoEditorBinding(),
      page: () => VideoPreview(),
    ),
    GetPage(
      name: '/video-submit',
      // binding: VideoEditorBinding(),
      page: () => VideoSubmit(),
    ),
    GetPage(
      name: '/sound-list',
      binding: SoundBinding(),
      page: () => SoundList(),
    ),
    GetPage(
      name: '/sound-cat-list',
      binding: SoundBinding(),
      page: () => SoundCatList(),
    ),
  ];
}
