// File generated manually for Firebase configuration
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBGpznBb4LRzFkLuToraY39VYpLfG4qYwE',
    appId: '1:707324540695:web:PLACEHOLDER',
    messagingSenderId: '707324540695',
    projectId: 'dormitory-attendance-app',
    authDomain: 'dormitory-attendance-app.firebaseapp.com',
    storageBucket: 'dormitory-attendance-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGpznBb4LRzFkLuToraY39VYpLfG4qYwE',
    appId: '1:707324540695:android:540d151627b02cb5f26952',
    messagingSenderId: '707324540695',
    projectId: 'dormitory-attendance-app',
    storageBucket: 'dormitory-attendance-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBGpznBb4LRzFkLuToraY39VYpLfG4qYwE',
    appId: '1:707324540695:ios:PLACEHOLDER',
    messagingSenderId: '707324540695',
    projectId: 'dormitory-attendance-app',
    storageBucket: 'dormitory-attendance-app.firebasestorage.app',
    iosBundleId: 'com.example.dormitoryAttendanceApp',
  );
}
