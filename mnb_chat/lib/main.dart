import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constant.dart';

import 'featurs/auth/models/user_model.dart';
import 'featurs/auth/presentaion/pages/auth_page.dart';
import 'featurs/auth/presentaion/provider/auth_provider.dart';
import 'featurs/chat/presentaion/pages/home_page.dart';
import 'featurs/chat/presentaion/providers/chat_provider.dart';
import 'featurs/chat/presentaion/providers/state_provider.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Constant.localPath = await getApplicationDocumentsDirectory();
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
          create: (context) => StateProvider(),
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
      theme: Constant.lightTheme,
      darkTheme: Constant.darkTheme,
      themeMode: context.watch<StateProvider>().themeMode,
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
              return const AuthPage();
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
