import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_app/firebase_options.dart';
import 'package:inventory_management_app/routes.dart';
import 'package:inventory_management_app/util/user_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSimplePreferences.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Inventory Manager',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
