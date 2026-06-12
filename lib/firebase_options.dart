// STUB — Ce fichier sera remplacé automatiquement par la commande :
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Étapes pour configurer Firebase :
//   1. Créer le projet sur console.firebase.google.com
//      → Activer : Authentication, Firestore, Storage, FCM, Remote Config
//   2. Exécuter : flutterfire configure
//   3. Ce fichier sera régénéré avec les vraies valeurs
//
// L'app compile et tourne en attendant, mais les fonctionnalités Firebase
// ne fonctionneront qu'après configuration.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Plateforme non configurée — exécuter: flutterfire configure',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCPwOQDI9_6htJXddaTgNHrdU0qimkkQww',
    appId: '1:601953997165:android:ef647c4be95eb8600a4a64',
    messagingSenderId: '601953997165',
    projectId: 'klinik-95a79',
    storageBucket: 'klinik-95a79.firebasestorage.app',
  );

  // TODO: remplacer par les vraies valeurs après flutterfire configure

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC72F8wJnBwvGeNI2Et6fRaPu4RNF6YVyI',
    appId: '1:601953997165:ios:f75888dc821484e20a4a64',
    messagingSenderId: '601953997165',
    projectId: 'klinik-95a79',
    storageBucket: 'klinik-95a79.firebasestorage.app',
    iosClientId: '601953997165-8otclie45bc2m20mg2ck05l1vq8erum5.apps.googleusercontent.com',
    iosBundleId: 'com.klinik.klinik',
  );

}