import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toast/toast.dart';
import '../../../../auth/models/user_model.dart';
import '../../../models/message.dart';

// ignore: must_be_immutable
class VoicPop extends StatefulWidget {
  DownloadTask? task;
  final bool isme;
  final MessageModel message;
  final String chatId;
  final UserModel friend;
  VoicPop({
    Key? key,
    required this.isme,
    this.task,
    required this.message,
    required this.chatId,
    required this.friend,
  }) : super(key: key);
  @override
  State<VoicPop> createState() => _VoicPopState();
}

class _VoicPopState extends State<VoicPop> {
  DownloadManager downloadManager = DownloadManager();
  late AudioPlayer audioPlayer;
  Duration durationOfVoice = Duration.zero;
  int maxDuration = 0;
  String timeInHour = '';
  String timeInminutes = '';
  String timeInsecond = '';
  @override
  void initState() {
    audioPlayer = AudioPlayer();
    var data = widget.message.duration.split(':');
    timeInHour = data[0];
    timeInminutes = data[1];
    timeInsecond = data[2];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    Size deviceSize = MediaQuery.of(context).size;
    if (!widget.isme) {
      if (widget.message.messageId != '') {
        FirebaseFirestore.instance
            .collection('messages')
            .doc(widget.chatId)
            .collection('msg')
            .doc(widget.message.messageId)
            .update({'isReseved': true});
      }
    }
    return widget.message.text == '' && !widget.isme
        ? const SizedBox.shrink()
        : InkWell(
            onLongPress: () async {
              print(widget.task!.status.value);
              //   /data/user/0/com.example.mnb_chat/cache/dd185a70-1c56-11ee-aa03-5f2f61d87fd4
            },
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
                constraints: BoxConstraints(
                    maxWidth: deviceSize.width * 0.77,
                    minWidth: deviceSize.width * 0.1),
                decoration: BoxDecoration(
                    color: widget.isme
                        ? Theme.of(context).colorScheme.onBackground
                        : Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.only(
                        topRight: const Radius.circular(15),
                        bottomLeft: Radius.circular(widget.isme ? 15 : 0),
                        bottomRight: Radius.circular(widget.isme ? 0 : 15),
                        topLeft: const Radius.circular(15))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 5),
                    Container(
                      decoration: BoxDecoration(
                          color: widget.isme
                              ? const Color.fromARGB(255, 132, 181, 220)
                              : const Color.fromARGB(255, 182, 170, 170),
                          shape: BoxShape.circle),
                      child: IconButton(
                        onPressed: () async {
                          if ((widget.message.reciverPath == null &&
                                  !widget.isme) ||
                              (widget.isme &&
                                  !await File(widget.message.senderPath!)
                                      .exists()) ||
                              (!widget.isme &&
                                  !await File(widget.message.reciverPath!)
                                      .exists())) {
                            if (widget.task == null ||
                                widget.task!.status.value !=
                                    DownloadStatus.downloading) {
                              downloadVoice(widget.message);
                            } else if (widget.task != null) {
                              downloadManager
                                  .pauseDownload(widget.message.text);
                              setState(() {});
                            }
                          } else {
                            if (audioPlayer.state == PlayerState.playing) {
                              audioPlayer.pause();
                            } else {
                              await audioPlayer
                                  .play(DeviceFileSource(widget.message.text));
                            }
                            durationOfVoice = await audioPlayer.getDuration() ??
                                Duration.zero;
                            maxDuration = durationOfVoice.inMilliseconds;
                            Timer.periodic(const Duration(milliseconds: 1),
                                (timer) {
                              if (audioPlayer.state != PlayerState.playing) {
                                timer.cancel();
                              }
                              setState(() {});
                            });
                          }
                        },
                        icon: FutureBuilder(
                          future: File(widget.message.senderPath!).exists(),
                          builder: (context, snapshot) {
                            return FutureBuilder(
                              future: widget.message.reciverPath == null
                                  ? Future.value(false)
                                  : File(widget.message.reciverPath!).exists(),
                              builder: (context, snapshot1) {
                                return (widget.message.reciverPath == null &&
                                            !widget.isme) ||
                                        (widget.isme &&
                                            snapshot.hasData &&
                                            !snapshot.data!) ||
                                        (!widget.isme &&
                                            snapshot1.hasData &&
                                            !snapshot1.data!)
                                    ? widget.task != null &&
                                            widget.task!.status.value !=
                                                DownloadStatus.completed &&
                                            widget.task!.status.value !=
                                                DownloadStatus.paused
                                        ? ValueListenableBuilder(
                                            valueListenable:
                                                widget.task!.progress,
                                            builder: (context, value, child) {
                                              if (value == 1.0) {
                                                if (!widget.isme) {
                                                  FirebaseFirestore.instance
                                                      .collection('messages')
                                                      .doc(widget.chatId)
                                                      .collection('msg')
                                                      .doc(widget
                                                          .message.messageId)
                                                      .update({
                                                    'reciverPath':
                                                        '/data/user/0/com.example.mnb_chat/cache/${widget.message.messageId}'
                                                  });
                                                }
                                                Timer.periodic(
                                                    const Duration(seconds: 1),
                                                    (timer) {
                                                  if (widget.isme &&
                                                          File(widget.message
                                                                  .senderPath!)
                                                              .existsSync() ||
                                                      !widget.isme &&
                                                          File(widget.message
                                                                  .reciverPath!)
                                                              .existsSync()) {
                                                    setState(() {});
                                                    timer.cancel();
                                                  }
                                                });
                                              }
                                              return Center(
                                                child: Stack(children: [
                                                  Align(
                                                    child: value == 0
                                                        ? const CircularProgressIndicator()
                                                        : CircularProgressIndicator(
                                                            value: value,
                                                          ),
                                                  ),
                                                  const Align(
                                                      child: Icon(Icons.cancel))
                                                ]),
                                              );
                                            },
                                          )
                                        : const Icon(Icons.download)
                                    : Icon(
                                        audioPlayer.state == PlayerState.playing
                                            ? Icons.pause
                                            : Icons.play_arrow);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder(
                            future: audioPlayer.getCurrentPosition(),
                            builder: (context, snapshot) => snapshot.hasData
                                ? SizedBox(
                                    width: deviceSize.width * 0.6,
                                    child: Slider(
                                      max: maxDuration * 1.0,
                                      value:
                                          snapshot.data!.inMilliseconds * 1.0,
                                      onChanged: (value) => audioPlayer.seek(
                                          Duration(
                                              milliseconds: value.toInt())),
                                    ),
                                  )
                                : const Text('')),
                        SizedBox(
                          width: deviceSize.width * 0.6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const SizedBox(width: 5),
                              Text(
                                '$timeInHour:$timeInminutes:$timeInsecond',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .color),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Text(
                                    '${(widget.message.date).toDate().hour}:${(widget.message.date).toDate().minute}',
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onError,
                                        fontSize: deviceSize.width * 0.035,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 5),
                                  widget.isme
                                      ? widget.message.isReseved == true
                                          ? const Icon(Icons.done_all)
                                          : widget.message.isSent == true
                                              ? const Icon(Icons.check)
                                              : const SpinKitCircle(
                                                  size: 30,
                                                  color: Colors.blueAccent,
                                                )
                                      : const SizedBox.shrink()
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
          );
  }

  downloadVoice(MessageModel message) async {
    print('start downlad');
    if (widget.message.text != '') {
      if (widget.task != null &&
          widget.task!.status.value == DownloadStatus.paused) {
        downloadManager.resumeDownload(message.text);
      } else {
        widget.task = await downloadManager
            .addDownload(message.text,
                '/data/user/0/com.example.mnb_chat/cache/${message.messageId}')
            .timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print('time out');
            Toast.show('time out');
            return null;
          },
        ).catchError((e) {
          print('hi there is an error');
          return null;
        });
      }
    } else {
      Toast.show('download link not valid');
    }
    setState(() {});
    downloadManager.getDownload(message.text);
  }
}
