import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../models/message.dart';

class RepliedMessagePop extends StatelessWidget {
  final MessageModel message;
  final bool isme;
  final String chatId;
  const RepliedMessagePop({
    Key? key,
    required this.message,
    required this.isme,
    required this.chatId,
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
    }
    return Container(
      constraints: BoxConstraints(
          maxWidth: deviceSize.width * 0.7, minWidth: deviceSize.width * 0.15),
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: isme
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSecondary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      message.fromName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge!.color),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      message.repliedText!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge!.color),
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message.text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${(message.date).toDate().hour}:${(message.date).toDate().minute}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
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
