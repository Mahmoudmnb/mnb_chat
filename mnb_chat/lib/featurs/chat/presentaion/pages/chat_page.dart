import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constant.dart';
import '../../../auth/models/user_model.dart';
import '../../models/message.dart';
import '../providers/chat_provider.dart';
import '../widgets/widgets.dart';

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
  @override
  void initState() {
    chatId = widget.chatId;
    friend = widget.friend;
    // context.read<ChatProvider>().controller = TextEditingController();
    // context.read<ChatProvider>().scrollController = ScrollController();
    if (context.read<ChatProvider>().isConvertedMode) {
      context.read<ChatProvider>().sendConvertedMessage(chatId);
    }
    super.initState();
  }

  @override
  void dispose() {
    // context.read<ChatProvider>().controller.dispose();
    // context.read<ChatProvider>().scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //* this is for getting device hight and width
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHight = deviceHight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top +
            MediaQuery.of(context).padding.bottom);
    return WillPopScope(
      onWillPop: () => context.read<ChatProvider>().willPopScopeOnTab(),
      child: SafeArea(
        child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            bottomNavigationBar: context.watch<ChatProvider>().showImojiPicker
                ? const EmojiPickerBuilder()
                : const SizedBox.shrink(),
            appBar: context.watch<ChatProvider>().isMainAppBar
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
                          controller:
                              context.watch<ChatProvider>().scrollController,
                          reverse: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (ctx, index) {
                            context
                                .read<ChatProvider>()
                                .selectedMessages
                                .add(false);
                            MessageModel message =
                                snapshot.data!.docs[index].data();
                            bool isme = message.from ==
                                Constant.currentUsre.phoneNamber;
                            return message.deletedFrom ==
                                    Constant.currentUsre.phoneNamber
                                ? const SizedBox.shrink()
                                : GestureDetector(
                                    onTap: () {
                                      context.read<ChatProvider>().onTabMessage(
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
                        return const Text('loading');
                        //! convert to animated loading widget
                      }
                    },
                  )),
                  !context.read<ChatProvider>().isMainAppBar &&
                          !context.read<ChatProvider>().editMode
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
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.phone,
                color: Theme.of(context).colorScheme.error,
              )),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.video_call,
                color: Theme.of(context).colorScheme.error,
              )),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                  child: TextButton(
                      onPressed: () async {},
                      child: Text(
                        'choose an image for background',
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
            onPressed: () => context.read<ChatProvider>().cancelOnTab(),
            icon: const Icon(Icons.cancel)),
        title: Text((context.watch<ChatProvider>().toMeSelectedMessage.length +
                context.watch<ChatProvider>().fromMeSelectedMessage.length)
            .toString()),
        actions: [
          context.watch<ChatProvider>().toMeSelectedMessage.isEmpty &&
                  context.read<ChatProvider>().fromMeSelectedMessage.length ==
                      1 &&
                  context.watch<ChatProvider>().selectedMessage!.type != 'Image'
              ? IconButton(
                  onPressed: () {
                    context.read<ChatProvider>().editOnTab(context);
                  },
                  icon: const Icon(Icons.edit))
              : const SizedBox.shrink(),
          IconButton(
              onPressed: () {
                context.read<ChatProvider>().copyOnTab();
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
