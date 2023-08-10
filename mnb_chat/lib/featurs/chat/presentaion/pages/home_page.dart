import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constant.dart';
import '../../../auth/models/user_model.dart';
import '../providers/chat_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/chat_page_widgets/bottom_navigation.dart';
import '../widgets/home_page_widgets/home_page_widgets.dart';
import '../widgets/home_page_widgets/profile_page.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  final UserModel user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String currentFriendNum = '';
  late PageController pageController;
  @override
  void initState() {
    pageController = PageController();

    getPermision();
    initInfo();
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top +
            MediaQuery.of(context).padding.bottom);
    Stream<QuerySnapshot<Map<String, dynamic>>> data = FirebaseFirestore
        .instance
        .collection('users')
        .doc(Constant.currentUsre.email)
        .collection('friends')
        .snapshots(includeMetadataChanges: true);
    var mainAppBar = AppBar(
      centerTitle: true,
      foregroundColor: Theme.of(context).colorScheme.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      title: Text(
        'MNB CHAT',
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).textTheme.titleLarge!.color),
      ),
      actions: [
        IconButton(
            onPressed: () async {
              SharedPreferences db = await SharedPreferences.getInstance();
              if (context.read<HomeProvider>().themeMode == ThemeMode.light) {
                context.read<HomeProvider>().setThemeMode = ThemeMode.dark;
                db.setString('Theme', 'dark');
              } else {
                context.read<HomeProvider>().setThemeMode = ThemeMode.light;
                db.setString('Theme', 'light');
              }
            },
            icon: Icon(
                context.watch<HomeProvider>().themeMode == ThemeMode.light
                    ? Icons.light_mode
                    : Icons.dark_mode))
      ],
    );
    var alternativeAppBar = AppBar(
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      title: Text(
        'convert to ...',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Theme.of(context).textTheme.titleLarge!.color),
      ),
      leading: IconButton(
          onPressed: () {
            context.read<ChatProvider>().setConvertedMode = false;
          },
          icon: const Icon(Icons.arrow_back)),
    );
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: !context.watch<ChatProvider>().isConvertedMode
            ? mainAppBar
            : alternativeAppBar,
        body: PageView(
            onPageChanged: (value) {
              context.read<ChatProvider>().setSelectedPage = value;
            },
            controller: context.watch<ChatProvider>().pageController,
            children: [
              FriendList(
                  deviceHeight: deviceHeight,
                  data: data,
                  currentFriendNum: currentFriendNum),
              ContactList(currentFriendNum: currentFriendNum),
              const ProfilePage(),
            ]),
        bottomNavigationBar: BottomNavigation(
          pageController: pageController,
        ));
  }

  void initInfo() {
    var androidSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var settings = InitializationSettings(android: androidSettings);
    late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    FirebaseMessaging.onMessage.listen((message) {
      flutterLocalNotificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (details) {
          if (currentFriendNum != '') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => ChatePage(
                  chatId: message.data['chatId'],
                  friend:
                      UserModel.fromJson(json.decode(message.data['friend']))),
            ));
          } else {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatePage(
                  chatId: message.data['chatId'],
                  friend:
                      UserModel.fromJson(json.decode(message.data['friend']))),
            ));
          }
        },
      );
      if (message.data['senderNum'] != currentFriendNum &&
          message.data['token'] != Constant.currentUsre.token) {
        BigTextStyleInformation bigTextStyleInformation =
            BigTextStyleInformation(
          message.notification!.body.toString(),
          htmlFormatBigText: true,
          contentTitle: message.notification!.title.toString(),
          htmlFormatContent: true,
        );
        AndroidNotificationDetails androidNotificationDetails =
            AndroidNotificationDetails(
          'dbfood',
          'dbfood',
          importance: Importance.high,
          styleInformation: bigTextStyleInformation,
          priority: Priority.high,
          playSound: true,
        );
        NotificationDetails details =
            NotificationDetails(android: androidNotificationDetails);
        flutterLocalNotificationsPlugin.show(
            0, message.notification!.title, message.notification!.body, details,
            payload: message.data['title']);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (currentFriendNum != '') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ChatePage(
              chatId: message.data['chatId'],
              friend: UserModel.fromJson(json.decode(message.data['friend']))),
        ));
      } else {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChatePage(
              chatId: message.data['chatId'],
              friend: UserModel.fromJson(json.decode(message.data['friend']))),
        ));
      }
    });
  }

  getPermision() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }
}
