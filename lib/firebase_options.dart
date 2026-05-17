import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA9MvZnouLITN0IHFOboklgHcdfTETYrSc',
    appId: '1:169012284832:web:placeholder',
    messagingSenderId: '169012284832',
    projectId: 'barangayboard-v1',
    authDomain: 'barangayboard-v1.firebaseapp.com',
    storageBucket: 'barangayboard-v1.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA9MvZnouLITN0IHFOboklgHcdfTETYrSc',
    appId: '1:169012284832:android:7469a26811dd33038a68c5',
    messagingSenderId: '169012284832',
    projectId: 'barangayboard-v1',
    storageBucket: 'barangayboard-v1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9MvZnouLITN0IHFOboklgHcdfTETYrSc',
    appId: '1:169012284832:ios:placeholder',
    messagingSenderId: '169012284832',
    projectId: 'barangayboard-v1',
    storageBucket: 'barangayboard-v1.firebasestorage.app',
    iosBundleId: 'com.example.barangayBoardV1',
  );
}
