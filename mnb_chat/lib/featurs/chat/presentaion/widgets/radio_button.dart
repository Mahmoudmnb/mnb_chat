import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';

class IconRadioButtton extends StatelessWidget {
  final int index;
  const IconRadioButtton({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
          border: Border.all(width: 2, color: Colors.white)),
      child: context.watch<ChatProvider>().selectedMessages[index]
          ? const Icon(Icons.check)
          : const SizedBox.shrink(),
    );
  }
}
