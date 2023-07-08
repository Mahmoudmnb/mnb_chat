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
                  label: Text(
                    'Reply',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).textTheme.titleLarge!.color),
                  ),
                  icon: Icon(Icons.arrow_back,
                      color: Theme.of(context).textTheme.titleLarge!.color))
              : const SizedBox.shrink(),
          InkWell(
              onTap: () {
                context.read<ChatProvider>().convertMessageOnTab(context);
              },
              child: Row(
                children: [
                  Text(
                    'Convert',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge!.color),
                  ),
                  const SizedBox(width: 5),
                  Icon(Icons.arrow_forward,
                      color: Theme.of(context).textTheme.titleLarge!.color)
                ],
              )),
        ],
      ),
    );
  }
}
