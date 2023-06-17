import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';


class EmojiPickerBuilder extends StatelessWidget {
  const EmojiPickerBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    double deviceHight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top +
            MediaQuery.of(context).padding.bottom);
    return SizedBox(
      height: deviceHight * 0.413,
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
