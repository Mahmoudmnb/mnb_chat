import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:mnb_chat/featurs/chat/presentaion/providers/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../../../auth/models/user_model.dart';
import '../../providers/chat_provider.dart';

class InputBottom extends StatefulWidget {
  final String chatId;
  final UserModel freind;
  const InputBottom({
    Key? key,
    required this.chatId,
    required this.freind,
  }) : super(key: key);

  @override
  State<InputBottom> createState() => _InputBottomState();
}

class _InputBottomState extends State<InputBottom> {
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  String nameOfVoice = '';
  Duration durationOfVoice = Duration.zero;
  @override
  void initState() {
    recorder.openRecorder();
    recorder.setSubscriptionDuration(const Duration(seconds: 1));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    Size deviceSize = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          context.watch<ChatProvider>().isReplied
              ? Container(
                  padding: const EdgeInsets.all(5),
                  width: double.infinity,
                  child: Row(
                    children: [
                      const SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).colorScheme.error,
                        size: deviceSize.width * 0.06,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context
                                .watch<ChatProvider>()
                                .selectedMessage!
                                .fromName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: deviceSize.width * 0.05),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            context.watch<ChatProvider>().selectedMessage!.text,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                          onPressed: () {
                            context.read<ChatProvider>().cancelReplyModeOnTab();
                          },
                          icon: Icon(
                            Icons.cancel,
                            color: Theme.of(context).colorScheme.error,
                            size: deviceSize.width * 0.07,
                          )),
                      const Divider(),
                    ],
                  ))
              : const SizedBox.shrink(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(
                onPressed: () {
                  context.read<ChatProvider>().emojiOnTab(context);
                },
                icon: Icon(
                  context.watch<ChatProvider>().showImojiPicker
                      ? Icons.keyboard
                      : Icons.face,
                  color: Theme.of(context).colorScheme.error,
                )),
            Container(
              constraints: const BoxConstraints(maxHeight: 100),
              padding: const EdgeInsets.all(7),
              width: context.watch<ChatProvider>().inputText == ''
                  ? deviceSize.width * 0.57
                  : deviceSize.width * 0.7,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).colorScheme.surfaceTint,
                        offset: const Offset(1, 1)),
                  ],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: context.watch<HomeProvider>().themeMode ==
                              ThemeMode.light
                          ? Colors.white
                          : Colors.black)),
              child: TextFormField(
                expands: false,
                onTap: () {
                  if (context
                      .read<ChatProvider>()
                      .focusNode
                      .enclosingScope!
                      .isFirstFocus) {
                    context.read<ChatProvider>().setShowImpjiPicker = false;
                  } else {
                    Timer.periodic(const Duration(seconds: 1), (timer) {
                      context.read<ChatProvider>().setShowImpjiPicker = false;
                      timer.cancel();
                    });
                  }
                },
                style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge!.color),
                decoration: InputDecoration.collapsed(
                    hintText: '',
                    hintStyle: TextStyle(
                      fontSize: deviceSize.width * 0.05,
                    )),
                autocorrect: true,
                focusNode: context.watch<ChatProvider>().focusNode,
                onChanged: (value) {
                  context.read<ChatProvider>().setInputText = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: context.watch<ChatProvider>().controller,
              ),
            ),
            context.watch<ChatProvider>().inputText != ''
                ? IconButton(
                    onPressed: () {
                      context
                          .read<ChatProvider>()
                          .editOrSendOnTab(widget.chatId, widget.freind);
                    },
                    icon: Icon(
                      context.watch<ChatProvider>().editMode
                          ? Icons.edit
                          : Icons.send,
                      color: Theme.of(context).colorScheme.error,
                    ))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () async {
                            File? image =
                                await context.read<ChatProvider>().pickImage();
                            if (image != null) {
                              context
                                  .read<ChatProvider>()
                                  .uploadImage(widget.chatId, image);
                            }
                          },
                          icon: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).colorScheme.error,
                          )),
                      Column(
                        children: [
                          StreamBuilder(
                            stream: recorder.onProgress,
                            builder: (context, snapshot) {
                              if (snapshot.hasData && recorder.isRecording) {
                                durationOfVoice = snapshot.data!.duration;
                                return Text(snapshot.data!.duration.inSeconds
                                    .toString());
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          InkWell(
                              onTap: () async {
                                if (recorder.isRecording) {
                                  var path = await recorder.stopRecorder();
                                  print(path);
                                  var voice = File(path!);
                                  context.read<ChatProvider>().uploadVoice(
                                      voice,
                                      nameOfVoice,
                                      durationOfVoice,
                                      widget.chatId);
                                  // var player = AudioPlayer();
                                  // player.play(DeviceFileSource(path));
                                } else {
                                  Toast.show('Long press to record');
                                }
                              },
                              onLongPress: () {
                                nameOfVoice =
                                    context.read<ChatProvider>().generateId();
                                recorder.startRecorder(toFile: nameOfVoice);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Icon(
                                  Icons.mic,
                                  color: recorder.isRecording
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              )),
                        ],
                      )
                    ],
                  )
          ]),
        ],
      ),
    );
  }
}
