import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mnb_chat/featurs/chat/presentaion/widgets/home_page_widgets/drawer.dart';
import 'package:mnb_chat/featurs/chat/presentaion/widgets/home_page_widgets/freind_tile.dart';
import 'package:provider/provider.dart';

import '../../../../core/constant.dart';
import '../../../auth/models/user_model.dart';
import '../providers/chat_provider.dart';

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
  late TabController tabController;
  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    getPermision();
    initInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    var data = FirebaseFirestore.instance
        .collection('users')
        .doc(Constant.currentUsre.phoneNamber)
        .collection('friends')
        .snapshots(includeMetadataChanges: true);
    var mainAppBar = AppBar(
      foregroundColor: Theme.of(context).colorScheme.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      title: Text(
        'MNB CHAT',
        style: TextStyle(color: Theme.of(context).textTheme.titleLarge!.color),
      ),
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
    );
    var alternativeAppBar = AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      title: Text(
        'convert to ...',
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
        body: TabBarView(controller: tabController, children: [
          Center(
            child: PageView(children: [
              StreamBuilder(
                  stream: data,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10),
                              child: FriendTile(
                                  snapshot: snapshot,
                                  index: index,
                                  currentFriendNum: currentFriendNum));
                        },
                      );
                    } else {
                      return const Text('please  wait');
                    }
                  }),
            ]),
          ),
          const Center(
            child: Text('hiifdf'),
          ),
          const Center(
            child: Text('hiifdf'),
          )
        ]),
        bottomSheet: Container(
          height: 50,
          width: double.infinity,
          color: Colors.purple[200],
          child: TabBar(controller: tabController, tabs: const [
            Text('data'),
            Text('fdlkjfdlkf'),
            Text('fdlkjfdlkf')
          ]),
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15))),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                context: context,
                builder: (ctx) {
                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('number',
                            isNotEqualTo: Constant.currentUsre.phoneNamber)
                        .snapshots(),
                    builder: (context, snapshot) => snapshot.hasData
                        ? ListView.builder(
                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (context, index) => ListTile(
                              title: Text(
                                  snapshot.data!.docs[index].data()['name']),
                              onTap: () async {
                                UserModel friend = UserModel.fromJson(
                                    snapshot.data!.docs[index].data());
                                context.read<ChatProvider>().friend = friend;
                                String chatId = await context
                                    .read<ChatProvider>()
                                    .createChat();
                                currentFriendNum = friend.phoneNamber;
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                      builder: (context) => ChatePage(
                                          chatId: chatId,
                                          friend: UserModel.fromJson(snapshot
                                              .data!.docs[index]
                                              .data())),
                                    ))
                                    .then((value) => currentFriendNum = '');
                              },
                            ),
                          )
                        : const Text('Please wait'),
                  );
                },
              );
            }),
        drawer: const HomePageDrawer());
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
      if (message.data['senderNum'] != currentFriendNum) {
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
