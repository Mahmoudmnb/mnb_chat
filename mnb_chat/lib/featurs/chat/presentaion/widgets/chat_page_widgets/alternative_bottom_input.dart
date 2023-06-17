import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';


class AlternativeBottomInput extends StatelessWidget {
  const AlternativeBottomInput({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.bottom -
            MediaQuery.of(context).padding.top);
    return Container(
      height: deviceHeight * 0.06,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          context.watch<ChatProvider>().toMeSelectedMessage.length == 1 &&
                      context
                          .read<ChatProvider>()
                          .fromMeSelectedMessage
                          .isEmpty ||
                  context.watch<ChatProvider>().toMeSelectedMessage.isEmpty &&
                      context
                              .read<ChatProvider>()
                              .fromMeSelectedMessage
                              .length ==
                          1
              ? TextButton.icon(
                  onPressed: () {
                    context.read<ChatProvider>().replyOnTab();
                  },
                  label: const Text(
                    'Reply',
                    style: TextStyle(fontSize: 20),
                  ),
                  icon: const Icon(Icons.arrow_back))
              : const SizedBox.shrink(),
          InkWell(
              onTap: () {
                context.read<ChatProvider>().convertMessageOnTab(context);
              },
              child: const Row(
                children: [
                  Text(
                    'Convert',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward)
                ],
              )),
        ],
      ),
    );
  }
}
