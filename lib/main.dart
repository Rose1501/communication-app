import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myproject/firebase_options.dart';
import 'package:user_repository/user_repository.dart';
import 'app.dart';

void main() async{
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Ensure the app runs in portrait mode only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final userRepository = FirebaseUserRepository();
  final advertisementRepository = AdvertisementFirebaseRepository();
  
  runApp(MainApp(
    userRepository: userRepository,
    advertisementRepository: advertisementRepository,
  ));
}
