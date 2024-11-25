// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyB-syhHOkeeHAGA0wgzWbrKxKsPxFfPozg',
    appId: '1:1071559938141:android:931ba176b765a5e6debdb4',
    messagingSenderId: '1071559938141',
    projectId: 'flush-d0dc1',
    databaseURL: 'https://flush-d0dc1-default-rtdb.firebaseio.com',
    storageBucket: 'flush-d0dc1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCMCEbX6484jBPMLDaiYFMoiaB1xe38RvQ',
    appId: '1:1071559938141:ios:4e8f9471f16fe97ddebdb4',
    messagingSenderId: '1071559938141',
    projectId: 'flush-d0dc1',
    databaseURL: 'https://flush-d0dc1-default-rtdb.firebaseio.com',
    storageBucket: 'flush-d0dc1.appspot.com',
    iosClientId: '1071559938141-lipchfphfodm0pg1c3k4p379hjej6hqg.apps.googleusercontent.com',
    iosBundleId: 'sheridan.tudballr.flush',
  );
}
