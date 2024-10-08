// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD2H6RFaNmQW9ncenn1sWXdBtqNlUrk8kI',
    appId: '1:1035210024290:android:04bd2437a7df819fc9f83b',
    messagingSenderId: '1035210024290',
    projectId: 'primecare-13cfb',
    storageBucket: 'primecare-13cfb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDXTfK6r5xLwQzQYGAANFiyn5sY66Kxhi4',
    appId: '1:1035210024290:ios:a2a794739636653ac9f83b',
    messagingSenderId: '1035210024290',
    projectId: 'primecare-13cfb',
    storageBucket: 'primecare-13cfb.appspot.com',
    androidClientId: '1035210024290-79m49gs9pi1vm2lm8euu5opid80q0lp3.apps.googleusercontent.com',
    iosClientId: '1035210024290-lunve6o7ojeo9jpoa3fd5petol4kkpjl.apps.googleusercontent.com',
    iosBundleId: 'com.example.mobiledashboard',
  );
}
