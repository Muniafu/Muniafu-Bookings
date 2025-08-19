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
    apiKey: 'AIzaSyAE_SSdG-ucBNk6YKs5-zFDDgPHX9erlTQ',
    appId: '1:327372824916:web:7718570cbaf1709eb8e8c1',
    messagingSenderId: '327372824916',
    projectId: 'elams-booking',
    authDomain: 'elams-booking.firebaseapp.com',
    databaseURL: 'https://elams-booking-default-rtdb.firebaseio.com',
    storageBucket: 'elams-booking.firebasestorage.app',
    measurementId: 'G-4YF1VETWBR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvfhKD0ETXUPTi9aNPSpIKUJ49AogpVY8',
    appId: '1:327372824916:android:4cc66569124e09afb8e8c1',
    messagingSenderId: '327372824916',
    projectId: 'elams-booking',
    databaseURL: 'https://elams-booking-default-rtdb.firebaseio.com',
    storageBucket: 'elams-booking.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCif6M5MZ74wX55m6R6l71ECsebA2nu0ew',
    appId: '1:327372824916:ios:07aed4551ddcdf05b8e8c1',
    messagingSenderId: '327372824916',
    projectId: 'elams-booking',
    databaseURL: 'https://elams-booking-default-rtdb.firebaseio.com',
    storageBucket: 'elams-booking.firebasestorage.app',
    iosBundleId: 'com.example.hotelBookingApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCif6M5MZ74wX55m6R6l71ECsebA2nu0ew',
    appId: '1:327372824916:ios:07aed4551ddcdf05b8e8c1',
    messagingSenderId: '327372824916',
    projectId: 'elams-booking',
    databaseURL: 'https://elams-booking-default-rtdb.firebaseio.com',
    storageBucket: 'elams-booking.firebasestorage.app',
    iosBundleId: 'com.example.hotelBookingApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDoT0S5Y9w13t9emKg8fSQl-FYhJSPdth0',
    appId: '1:327372824916:web:8afdc184b1f45335b8e8c1',
    messagingSenderId: '327372824916',
    projectId: 'elams-booking',
    authDomain: 'elams-booking.firebaseapp.com',
    databaseURL: 'https://elams-booking-default-rtdb.firebaseio.com',
    storageBucket: 'elams-booking.firebasestorage.app',
    measurementId: 'G-CX6JYF504K',
  );

}