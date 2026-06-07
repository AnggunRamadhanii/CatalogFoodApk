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
    apiKey: 'AIzaSyCX2_OuUuJHGkonCAt8e73ckU8V4GpMY2o',
    appId: '1:1043041897786:web:de5ce3b1e90b8336b05403',
    messagingSenderId: '1043041897786',
    projectId: 'foodcatalog-bdeaf',
    authDomain: 'foodcatalog-bdeaf.firebaseapp.com',
    storageBucket: 'foodcatalog-bdeaf.firebasestorage.app',
    measurementId: 'G-RCEXKMRGPT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJm45zJW4ydWYPJJwJv5IFFRXNBE4yK4k',
    appId: '1:1043041897786:android:ee28113dbb39d3cbb05403',
    messagingSenderId: '1043041897786',
    projectId: 'foodcatalog-bdeaf',
    storageBucket: 'foodcatalog-bdeaf.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCwBgtPtHrx4Z6IroLiKavSNc7feIGFXio',
    appId: '1:1043041897786:ios:d871e31c8c1b672db05403',
    messagingSenderId: '1043041897786',
    projectId: 'foodcatalog-bdeaf',
    storageBucket: 'foodcatalog-bdeaf.firebasestorage.app',
    iosBundleId: 'com.example.catalogfood',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCwBgtPtHrx4Z6IroLiKavSNc7feIGFXio',
    appId: '1:1043041897786:ios:d871e31c8c1b672db05403',
    messagingSenderId: '1043041897786',
    projectId: 'foodcatalog-bdeaf',
    storageBucket: 'foodcatalog-bdeaf.firebasestorage.app',
    iosBundleId: 'com.example.catalogfood',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCX2_OuUuJHGkonCAt8e73ckU8V4GpMY2o',
    appId: '1:1043041897786:web:f611bdfa6c873af7b05403',
    messagingSenderId: '1043041897786',
    projectId: 'foodcatalog-bdeaf',
    authDomain: 'foodcatalog-bdeaf.firebaseapp.com',
    storageBucket: 'foodcatalog-bdeaf.firebasestorage.app',
    measurementId: 'G-0RGEFH0C4P',
  );
}
