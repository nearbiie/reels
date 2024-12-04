
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA4VDbz26VjzLVbSJ185PqSsJZSl7wGlGs',
    appId: '1:171867703068:web:efbb8b95eddf95bc665cd9',
    messagingSenderId: '171867703068',
    projectId: 'monthly-bucket-app',
    authDomain: 'monthly-bucket-app.firebaseapp.com',
    storageBucket: 'monthly-bucket-app.appspot.com',
    measurementId: 'G-PZFP9YNXPQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBdofy8VepxMR3EDC8l3C3KsarerTdxFBA',
    appId: '1:350815494171:android:0f8645d820856e9812d8be',
    messagingSenderId: '350815494171',
    projectId: 'leuke-6d736',
    storageBucket: 'leuke-6d736.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDjK7wZHPw1bodf1LuYFjmBK7cSNRwgaSQ',
    appId: '1:171867703068:ios:3ec3847c07356631665cd9',
    messagingSenderId: '171867703068',
    projectId: 'monthly-bucket-app',
    storageBucket: 'monthly-bucket-app.appspot.com',
    iosBundleId: 'com.example.monthlyBucket',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDjK7wZHPw1bodf1LuYFjmBK7cSNRwgaSQ',
    appId: '1:171867703068:ios:3ec3847c07356631665cd9',
    messagingSenderId: '171867703068',
    projectId: 'monthly-bucket-app',
    storageBucket: 'monthly-bucket-app.appspot.com',
    iosBundleId: 'com.example.monthlyBucket',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA4VDbz26VjzLVbSJ185PqSsJZSl7wGlGs',
    appId: '1:171867703068:web:58ab09d9d58efc68665cd9',
    messagingSenderId: '171867703068',
    projectId: 'monthly-bucket-app',
    authDomain: 'monthly-bucket-app.firebaseapp.com',
    storageBucket: 'monthly-bucket-app.appspot.com',
    measurementId: 'G-XELL9HESK3',
  );
}
