import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY',
    appId: '1:724703414149:android:25ed0ae3364cce15f566ec',
    messagingSenderId: '724703414149',
    projectId: 'al-anwar-institute',
    storageBucket: 'al-anwar-institute.firebasestorage.app',
  );
}
