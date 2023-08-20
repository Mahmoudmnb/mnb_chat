import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mnb_chat/core/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constant.dart';
import '../../../auth/models/user_model.dart';
import '../../models/message.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_page_widgets/chat_page_widgets.dart';
import 'loading_page.dart';

class ChatePage extends StatefulWidget {
  final UserModel friend;
  final String chatId;
  const ChatePage({required this.chatId, required this.friend, super.key});
  @override
  State<ChatePage> createState() => _ChatePageState();
}

class _ChatePageState extends State<ChatePage> {
  late String chatId;
  late UserModel friend;
  double deviceWidth = 0;
  double deviceHight = 0;
  late ChatProvider readContext;
  late ChatProvider watchContext;
  @override
  initState() {
    chatId = widget.chatId;
    friend = widget.friend;
    if (context.read<ChatProvider>().isConvertedMode) {
      context.read<ChatProvider>().sendConvertedMessage(chatId);
    }
    super.initState();
  }

  Future<double> getHeightOfKeyBoard() async {
    SharedPreferences db = await SharedPreferences.getInstance();
    return db.getDouble('heightOfKeyBoard')!;
  }

  @override
  void dispose() {
    readContext.friend = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    readContext = context.read<ChatProvider>();
    watchContext = context.watch<ChatProvider>();
    //* this is for getting device hight and width

    deviceWidth = MediaQuery.of(context).size.width;
    deviceHight = deviceHight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top +
            MediaQuery.of(context).padding.bottom);
    return WillPopScope(
      onWillPop: () => readContext.willPopScopeOnTab(),
      child: SafeArea(
        child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            bottomNavigationBar: watchContext.showImojiPicker
                ? EmojiPickerBuilder(h: Constant.heightOfKeyboard)
                : const SizedBox.shrink(),
            appBar: watchContext.isMainAppBar
                ? mainAppBar(friend.name)
                : aternativeAppBar(),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('messages')
                        .doc(chatId)
                        .collection('msg')
                        .orderBy('date', descending: true)
                        .withConverter(
                            fromFirestore: (snapshot, options) =>
                                MessageModel.fromMap(snapshot.data()!),
                            toFirestore: (value, options) => value.toMap())
                        .snapshots(),
                    builder: (con, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          padding: const EdgeInsets.all(5),
                          physics: const BouncingScrollPhysics(),
                          controller: watchContext.scrollController,
                          reverse: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (ctx, index) {
                            context
                                .read<ChatProvider>()
                                .selectedMessages
                                .add(false);
                            MessageModel message =
                                snapshot.data!.docs[index].data();
                            bool isme =
                                message.from == Constant.currentUsre.email;
                            return message.deletedFrom ==
                                    Constant.currentUsre.email
                                ? const SizedBox.shrink()
                                : GestureDetector(
                                    onTap: () {
                                      readContext.onTabMessage(
                                          index, isme, message, context);
                                    },
                                    onLongPress: () {
                                      context
                                          .read<ChatProvider>()
                                          .onLongPressMessage(
                                              message,
                                              isme,
                                              index,
                                              snapshot.data!.docs.length);
                                    },
                                    child: MessageRow(
                                        chatId: chatId,
                                        index: index,
                                        isme: isme,
                                        friend: friend,
                                        message: message));
                          },
                        );
                      } else {
                        return Center(
                          child: LoadingPage(
                              fullWidth: false,
                              deviceSize: MediaQuery.of(context).size),
                        );
                      }
                    },
                  )),
                  !readContext.isMainAppBar && !readContext.editMode
                      ? const AlternativeBottomInput()
                      : InputBottom(chatId: chatId, freind: friend),
                ],
              ),
            )),
      ),
    );
  }

  AppBar mainAppBar(String name) => AppBar(
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.surface,
        backgroundColor:
            Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
        leadingWidth: deviceWidth * 0.1,
        actions: [
          PopupMenuButton(
            color: Theme.of(context).colorScheme.background.withOpacity(0.9),
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.surface,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                  child: TextButton(
                      onPressed: () async {},
                      child: Text(
                        'Choose an image for background',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: deviceWidth * 0.035,
                          color: Theme.of(context).textTheme.titleLarge!.color,
                        ),
                      ))),
              PopupMenuItem(
                  child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Clear chat history',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: deviceWidth * 0.035,
                          color: Theme.of(context).textTheme.titleLarge!.color,
                        ),
                      ))),
            ],
          )
        ],
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.nameColors[getNameLetters(name)[0]],
              child: Text(
                getNameLetters(name),
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: deviceWidth * 0.03),
            SizedBox(
              width: deviceWidth * 0.5,
              child: Text(
                name,
                style: TextStyle(
                    fontSize: deviceWidth * 0.05,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge!.color),
              ),
            ),
          ],
        ),
      );

  AppBar aternativeAppBar() => AppBar(
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.surface,
        backgroundColor:
            Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
        leading: IconButton(
            onPressed: () => readContext.cancelOnTab(),
            icon: const Icon(Icons.cancel)),
        title: Text(
          (watchContext.toMeSelectedMessage.length +
                  watchContext.fromMeSelectedMessage.length)
              .toString(),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          watchContext.toMeSelectedMessage.isEmpty &&
                  watchContext.fromMeSelectedMessage.length == 1 &&
                  watchContext.fromMeSelectedMessage[0].type == 'Message'
              ? IconButton(
                  onPressed: () {
                    readContext.editOnTab(context);
                  },
                  icon: const Icon(Icons.edit))
              : const SizedBox.shrink(),
          IconButton(
              onPressed: () {
                readContext.copyOnTab();
              },
              icon: const Icon(Icons.copy)),
          IconButton(
              onPressed: () async {
                context.read<ChatProvider>().deleteOnTab(
                    chatId, context, friend, deviceHight, deviceWidth);
              },
              icon: const Icon(Icons.delete)),
        ],
      );
  String getNameLetters(String name) {
    var splitedName = name.split(' ');
    var f = splitedName.length == 1
        ? splitedName.first.characters.first
        : splitedName.first.characters.first +
            splitedName.last.characters.first;
    return f.toUpperCase();
  }
}
