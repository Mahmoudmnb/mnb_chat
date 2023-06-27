import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../auth/models/user_model.dart';
import '../../../models/message.dart';

class MessagePop extends StatelessWidget {
  final bool isme;
  final MessageModel message;
  final String chatId;
  final UserModel friend;
  const MessagePop({
    Key? key,
    required this.isme,
    required this.message,
    required this.chatId,
    required this.friend,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    if (!isme) {
      if (message.messageId != '') {
        FirebaseFirestore.instance
            .collection('messages')
            .doc(chatId)
            .collection('msg')
            .doc(message.messageId)
            .update({'isReseved': true});
      }
    } else {
      if (message.isReseved == true && message.isSent == false) {
        FirebaseFirestore.instance
            .collection('messages')
            .doc(chatId)
            .collection('msg')
            .doc(message.messageId)
            .update({'isSent': true});
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      constraints: BoxConstraints(
          maxWidth: deviceSize.width * 0.7, minWidth: deviceSize.width * 0.15),
      decoration: BoxDecoration(
          color: isme
              ? Theme.of(context).colorScheme.onBackground
              : Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.only(
              topRight: const Radius.circular(15),
              bottomLeft: Radius.circular(isme ? 15 : 0),
              bottomRight: Radius.circular(isme ? 0 : 15),
              topLeft: const Radius.circular(15))),
      child: Column(
        crossAxisAlignment:
            isme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            message.text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: deviceSize.width * 0.05,
                color: Theme.of(context).textTheme.titleLarge!.color),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(message.date).toDate().hour}:${(message.date).toDate().minute}',
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: deviceSize.width * 0.035,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 5),
              isme
                  ? message.isReseved == true
                      ? const Icon(Icons.done_all)
                      : message.isSent == true
                          ? const Icon(Icons.check)
                          : const SpinKitCircle(
                              size: 30,
                              color: Colors.blueAccent,
                            )
                  : const SizedBox.shrink()
            ],
          ),
        ],
      ),
    );
  }
}
