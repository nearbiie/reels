import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leuke/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../src/core.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void _enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
AndroidNotificationChannel? channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

Future<void> main() async {
  _enablePlatformOverrideForDesktop();
  await GetStorage.init();
/*
  ErrorWidget.builder = (FlutterErrorDetails details) {
    //bool inDebug = false;
    assert(() {
      // inDebug = true;
      return true;
    }());
    return Material(
      child: Container(
        alignment: Alignment.center,
        color: Get.theme.primaryColor,
        child: InkWell(
          onTap: () {
            videoRepo.dataLoaded.value = true;
            videoRepo.homeCon.value.showHomeLoader.value = false;
          },
          child: Text(
            "",
            style: TextStyle(color: mainService.setting.value.headingColor),
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  };
*/

  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin!.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel!);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  HttpOverrides.global = new MyHttpOverrides();
  FlutterNativeSplash.remove();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    permission();

    super.initState();
  }

  permission() async {
    await FirebaseMessaging.instance.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );
    //Permission for camera...
    final cameraStatus = await Permission.camera.status;
    if (cameraStatus == PermissionStatus.denied) {
      await Permission.camera.request();
    } else if (cameraStatus == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }

    //Permission for storage...
    final storageStatus = await Permission.storage.status;
    if (storageStatus == PermissionStatus.denied) {
      await Permission.storage.request();
    } else if (storageStatus == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }

    //Permission for microphone...
    final microphoneStatus = await Permission.microphone.status;
    if (microphoneStatus == PermissionStatus.denied) {
      await Permission.microphone.request();
    } else if (microphoneStatus == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return GetMaterialApp(
      builder: EasyLoading.init(),

      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 400),
      getPages: Routes.route,
      // translations: Language(),
      locale: Locale(GetStorage().read("language_code") ?? "en", GetStorage().read("country_code") ?? "US"),
      initialRoute: '/',
      // title: '${GlobalConfiguration().get('app_name')}',
      title: appName,
      navigatorObservers: [routeObserver],
      themeMode: ThemeMode.light,
      theme: ThemeData(
        fontFamily: 'ProductSans',
        primaryColor: glLightPrimaryColor,
        highlightColor: glAccentColor,
        brightness: Brightness.light,
        indicatorColor: glLightIconColor,
        dividerColor: glLightDividerColor,
        shadowColor: glLightBoxShadowColor,
        hintColor: glLightHintColor,
        iconTheme: IconThemeData(color: glLightIconColor),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: glLightButtonBGColor,
            foregroundColor: glLightButtonTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
            textStyle: GoogleFonts.poppins().copyWith(fontSize: buttonTextFontSize, color: glLightButtonTextColor, fontWeight: FontWeight.w400),
          ),
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.poppins().copyWith(fontSize: titleLarge, color: glLightHeadingColor, fontWeight: FontWeight.w400),
          titleMedium: GoogleFonts.poppins().copyWith(fontSize: titleMedium, color: glLightHeadingColor, fontWeight: FontWeight.w400),
          titleSmall: GoogleFonts.poppins().copyWith(fontSize: titleSmall, color: glLightHeadingColor, fontWeight: FontWeight.w400),
          headlineSmall: GoogleFonts.poppins().copyWith(fontSize: headlineSmall, color: glLightHeadingColor, fontWeight: FontWeight.bold),
          headlineMedium: GoogleFonts.poppins().copyWith(fontSize: headlineMedium, color: glLightHeadingColor, fontWeight: FontWeight.bold),
          headlineLarge: GoogleFonts.poppins().copyWith(fontSize: headlineLarge, color: glLightHeadingColor, fontWeight: FontWeight.bold),
          bodyLarge: GoogleFonts.poppins().copyWith(fontSize: bodyLarge, color: glLightHeadingColor, fontWeight: FontWeight.w400),
          bodyMedium: GoogleFonts.poppins().copyWith(fontSize: bodyMedium, color: glLightHeadingColor, fontWeight: FontWeight.w400),
          bodySmall: GoogleFonts.poppins().copyWith(fontSize: bodySmall, color: glLightHeadingColor, fontWeight: FontWeight.w400),
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: 'ProductSans',
        primaryColor: glDarkPrimaryColor,
        highlightColor: glAccentColor,
        brightness: Brightness.dark,
        indicatorColor: glAccentColor,
        dividerColor: glDarkDividerColor,
        shadowColor: glDarkBoxShadowColor,
        hintColor: glDarkHintColor,
        iconTheme: IconThemeData(color: glDarkIconColor),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: glDarkButtonBGColor,
            foregroundColor: glDarkButtonTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
            textStyle: GoogleFonts.poppins().copyWith(fontSize: buttonTextFontSize, color: glDarkButtonTextColor, fontWeight: FontWeight.w400),
          ),
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.poppins().copyWith(fontSize: titleLarge, color: glDarkHeadingColor, fontWeight: FontWeight.w400),
          titleMedium: GoogleFonts.poppins().copyWith(fontSize: titleMedium, color: glDarkHeadingColor, fontWeight: FontWeight.w400),
          titleSmall: GoogleFonts.poppins().copyWith(fontSize: titleSmall, color: glDarkHeadingColor, fontWeight: FontWeight.w400),
          headlineSmall: GoogleFonts.poppins().copyWith(fontSize: headlineSmall, color: glDarkHeadingColor, fontWeight: FontWeight.bold),
          headlineMedium: GoogleFonts.poppins().copyWith(fontSize: headlineMedium, color: glDarkHeadingColor, fontWeight: FontWeight.bold),
          headlineLarge: GoogleFonts.poppins().copyWith(fontSize: headlineLarge, color: glDarkHeadingColor, fontWeight: FontWeight.bold),
          bodyLarge: GoogleFonts.poppins().copyWith(fontSize: bodyLarge, color: glDarkHeadingColor, fontWeight: FontWeight.w400),
          bodyMedium: GoogleFonts.poppins().copyWith(fontSize: bodyMedium, color: glDarkHeadingColor, fontWeight: FontWeight.w400),
          bodySmall: GoogleFonts.poppins().copyWith(fontSize: bodySmall, color: glDarkHeadingColor, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
