import 'package:flutter/material.dart';
import 'package:mnb_chat/featurs/chat/presentaion/providers/state_provider.dart';
import 'package:mnb_chat/featurs/chat/presentaion/widgets/radio_button.dart';
import 'package:provider/provider.dart';

import '../../../auth/models/user_model.dart';
import '../../models/message.dart';
import '../providers/chat_provider.dart';
import 'image_pop.dart';
import 'message_pop.dart';
import 'repied_message_pop.dart';

class MessageRow extends StatelessWidget {
  final int index;
  final bool isme;
  final UserModel friend;
  final MessageModel message;
  final String chatId;

  const MessageRow({
    Key? key,
    required this.chatId,
    required this.index,
    required this.isme,
    required this.friend,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: !context.read<ChatProvider>().isMainAppBar &&
                  context.watch<ChatProvider>().selectedMessages[index]
              ? context.watch<StateProvider>().themeMode == ThemeMode.light
                  ? Colors.grey.shade400
                  : Colors.white24
              : Colors.transparent),
      child: Column(
        children: [
          Row(
            children: [
              !context.watch<ChatProvider>().isMainAppBar
                  ? IconRadioButtton(index: index)
                  : const SizedBox.shrink(),
              Expanded(
                child: Container(
                    alignment: message.from == friend.phoneNamber
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: message.type == 'Image'
                        ? ImagePop(
                            chatId: chatId,
                            message: message,
                            deviceSize: deviceSize,
                          )
                        : message.isreplied
                            ? RepliedMessagePop(
                                chatId: chatId, isme: isme, message: message)
                            : MessagePop(
                                friend: friend,
                                chatId: chatId,
                                isme: isme,
                                message: message,
                              )),
              ),
            ],
          ),
          const SizedBox(height: 2)
        ],
      ),
    );
  }
}
