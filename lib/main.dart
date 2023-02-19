import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:memory_ez/envConfig.dart';
import 'package:memory_ez/firebase_options_dev.dart';
import 'package:memory_ez/firebase_options_prod.dart';
import 'package:memory_ez/routes.dart';
import 'package:memory_ez/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (EnvConfig.isDev) {
    await Firebase.initializeApp(
      options: DevFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  var firestore = FirebaseFirestore.instance;
  if (EnvConfig.isDev) {
    await FirebaseAuth.instance.useAuthEmulator(EnvConfig.firebaseIp, 9099);

    firestore.useFirestoreEmulator(EnvConfig.firebaseIp, 8080);
  }
  firestore.settings = const Settings(persistenceEnabled: false);

  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory EZ',
      theme: appTheme,
      themeMode: ThemeMode.dark,
      darkTheme: appDarkTheme,
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
