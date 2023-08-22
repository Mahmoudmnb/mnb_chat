import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mnb_chat/core/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constant.dart';

import 'featurs/Auth/presentation/pages/auth_page.dart';
import 'featurs/Auth/presentation/provider/auth_provider.dart';
import 'featurs/auth/models/user_model.dart';
import 'featurs/chat/presentaion/pages/home_page.dart';
import 'featurs/chat/presentaion/providers/providers.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

ThemeMode? themeMode;
Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, persistenceEnabled: true);

  //* his is to know the path of the application to store files
  Constant.appPath = await getApplicationDocumentsDirectory();
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  SharedPreferences db = await SharedPreferences.getInstance();
  //* this is to know the height of the keyboard
  Constant.heightOfKeyboard = db.getDouble('heightOfKeyBoard') ?? 0;

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //* set theme for the app
  String th = db.getString('Theme') ?? '';
  themeMode = th.isEmpty || th == 'light' ? ThemeMode.light : ThemeMode.dark;
  //* request permissoin for mic
  Permission.microphone.request();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeProvider(themeMode ?? ThemeMode.light),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: context.watch<HomeProvider>().themeMode,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data?.getString('currentUser') != null) {
              UserModel currentUser = UserModel.fromJson(
                  json.decode(snapshot.data!.getString('currentUser')!));
              Constant.currentUsre = currentUser;
              return HomePage(user: currentUser);
            } else {
              return AuthPage();
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
