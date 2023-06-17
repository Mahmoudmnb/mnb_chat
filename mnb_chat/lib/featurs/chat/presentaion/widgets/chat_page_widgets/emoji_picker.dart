// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';

class EmojiPickerBuilder extends StatelessWidget {
  final double h;
  const EmojiPickerBuilder({
    Key? key,
    required this.h,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double deviceHight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top +
            MediaQuery.of(context).padding.bottom);
    return SizedBox(
      height: h,
      child: EmojiPicker(
        textEditingController: context.watch<ChatProvider>().controller,
        config: Config(
          bgColor: Theme.of(context).colorScheme.onSurface,
          columns: 7,
          buttonMode: ButtonMode.MATERIAL,
        ),
        onEmojiSelected: (emoji, category) {
          context.read<ChatProvider>().onEmojiSelected(category);
        },
      ),
    );
  }
}
