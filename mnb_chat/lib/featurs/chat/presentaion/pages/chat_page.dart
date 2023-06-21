import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constant.dart';
import '../../../auth/models/user_model.dart';
import '../../models/message.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_page_widgets/chat_page_widgets.dart';

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
                        return const Text('loading',
                                      overflow: TextOverflow.ellipsis,
                        
                        );
                        //! convert to animated loading widget
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
        foregroundColor: Theme.of(context).colorScheme.error,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leadingWidth: deviceWidth * 0.1,
        actions: [
          PopupMenuButton(
            color: Theme.of(context).colorScheme.surface,
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.error,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                  child: TextButton(
                      onPressed: () async {},
                      child: Text(
                        'choose an image for background',
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
              backgroundColor:
                  Theme.of(context).colorScheme.error.withOpacity(0.3),
            ),
            SizedBox(width: deviceWidth * 0.03),
            Text(
              name,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: deviceWidth * 0.07,
                  overflow: TextOverflow.ellipsis,
                  color: Theme.of(context).textTheme.titleLarge!.color),
            ),
          ],
        ),
      );

  AppBar aternativeAppBar() => AppBar(
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.error,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
            onPressed: () => readContext.cancelOnTab(),
            icon: const Icon(Icons.cancel)),
        title: Text((watchContext.toMeSelectedMessage.length +
                watchContext.fromMeSelectedMessage.length)
            .toString()
            
            ,

overflow: TextOverflow.ellipsis,
            ),
        actions: [
          watchContext.toMeSelectedMessage.isEmpty &&
                  readContext.fromMeSelectedMessage.length == 1 &&
                  watchContext.selectedMessage!.type != 'Image'
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
                context
                    .read<ChatProvider>()
                    .deleteOnTab(chatId, context, friend);
              },
              icon: const Icon(Icons.delete)),
        ],
      );
}
