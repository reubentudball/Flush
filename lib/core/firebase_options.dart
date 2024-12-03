import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';
import './secrets.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: Secrets.androidApiKey,
    appId: Secrets.androidAppId,
    messagingSenderId: Secrets.androidMessagingSenderId,
    projectId: Secrets.androidProjectId,
    databaseURL: Secrets.androidDatabaseURL,
    storageBucket: Secrets.androidStorageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: Secrets.iosApiKey,
    appId: Secrets.iosAppId,
    messagingSenderId: Secrets.iosMessagingSenderId,
    projectId: Secrets.iosProjectId,
    databaseURL: Secrets.iosDatabaseURL,
    storageBucket: Secrets.iosStorageBucket,
    iosClientId: Secrets.iosClientId,
    iosBundleId: Secrets.iosBundleId,
  );
}
