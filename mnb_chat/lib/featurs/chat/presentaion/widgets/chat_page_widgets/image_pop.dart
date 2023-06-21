// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../../core/constant.dart';
import '../../../models/message.dart';

class ImagePop extends StatefulWidget {
  DownloadTask? task;
  final MessageModel message;
  final String chatId;
  Size deviceSize;
  ImagePop({
    Key? key,
    this.task,
    required this.message,
    required this.chatId,
    required this.deviceSize,
  }) : super(key: key);

  @override
  State<ImagePop> createState() => _ImagePopState();
}

class _ImagePopState extends State<ImagePop> {
  DownloadManager downloadManager = DownloadManager();
  late double imageHeight = 0;
  late double imageWidth = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getImageSize(widget.message);
    bool isMe = widget.message.from == Constant.currentUsre.email;
    Size deviceSize = MediaQuery.of(context).size;
    if (!isMe) {
      if (widget.message.messageId != '') {
        FirebaseFirestore.instance
            .collection('messages')
            .doc(widget.chatId)
            .collection('msg')
            .doc(widget.message.messageId)
            .update({'isReseved': true});
      }
    }
    return widget.message.text == '' && !isMe
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: () {
              imageOnTab(isMe);
            },
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(15)),
                child: Stack(
                  children: [
                    isMe && File(widget.message.senderPath!).existsSync()
                        ? Container(
                            constraints: BoxConstraints(
                                maxHeight: imageHeight, maxWidth: imageWidth),
                            child: Stack(children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                      File(widget.message.senderPath!))),
                            ]),
                          )
                        : SizedBox(
                            height: imageHeight,
                            width: imageWidth,
                            child: Stack(
                              children: [
                                widget.message.reciverPath == null
                                    ? SizedBox(
                                        child: widget.task == null ||
                                                widget.task!.status.value ==
                                                        DownloadStatus.paused &&
                                                    widget.task!.status.value !=
                                                        DownloadStatus
                                                            .downloading
                                            ? const Align(
                                                child: Icon(
                                                MdiIcons.downloadOutline,
                                                size: 40,
                                              ))
                                            : const SizedBox.shrink())
                                    : File(widget.message.reciverPath!)
                                            .isAbsolute
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Image.file(
                                              File(widget.message.reciverPath!),
                                            ),
                                          )
                                        : const CircularProgressIndicator(
                                            value: 1,
                                          ),
                                widget.message.reciverPath == null &&
                                        widget.task != null &&
                                        widget.task!.status.value !=
                                            DownloadStatus.completed &&
                                        widget.task!.status.value !=
                                            DownloadStatus.paused
                                    ? ValueListenableBuilder(
                                        valueListenable: widget.task!.progress,
                                        builder: (context, value, child) {
                                          if (value == 1.0) {
                                            FirebaseFirestore.instance
                                                .collection('messages')
                                                .doc(widget.chatId)
                                                .collection('msg')
                                                .doc(widget.message.messageId)
                                                .update({
                                              'reciverPath':
                                                  '${Constant.localPath!.path}${widget.message.messageId}.jpg'
                                            });
                                          }
                                          return Center(
                                            child: Stack(children: [
                                              Align(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: value,
                                                ),
                                              ),
                                              const Align(
                                                  child: Icon(Icons.cancel))
                                            ]),
                                          );
                                        },
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            )),
                    Positioned(
                      bottom: 3,
                      right: 3,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade500,
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${(widget.message.date).toDate().hour}:${(widget.message.date).toDate().minute}',
overflow: TextOverflow.ellipsis,
                            
                              style: TextStyle(
                                  fontSize: deviceSize.width * 0.04,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 3),
                            isMe
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
                        ),
                      ),
                    ),
                  ],
                )));
  }

  imageOnTab(isMe) {
    if ((widget.message.reciverPath == null &&
            widget.message.text != '' &&
            !isMe) ||
        !File(widget.message.senderPath!).isAbsolute) {
      if (widget.task == null) {
        downloadImage(widget.message);
      } else if (widget.task!.status.value == DownloadStatus.downloading) {
        setState(() {});
        downloadManager.pauseDownload(widget.message.text);
      } else if (widget.task!.status.value == DownloadStatus.paused) {
        setState(() {});
        downloadManager.resumeDownload(widget.message.text);
      }
      if (isMe && widget.message.text != '') {
        var image = Image.file(File(widget.message.senderPath!)).image;
        showImageViewer(context, image);
      } else if (!isMe && widget.message.reciverPath != null) {
        var image = Image.file(File(widget.message.reciverPath!)).image;
        showImageViewer(context, image);
      }
    } else {
      if (isMe && widget.message.senderPath != null) {
        showImageViewer(context, FileImage(File(widget.message.senderPath!)));
      } else if (widget.message.reciverPath != null) {
        showImageViewer(context, FileImage(File(widget.message.reciverPath!)));
      }
    }
  }

  downloadImage(MessageModel message) async {
    bool isMe = message.from == Constant.currentUsre.email;
    if (!isMe && message.reciverPath == null && message.text != '') {
      widget.task = await downloadManager.addDownload(
          message.text, '${Constant.localPath!.path}${message.messageId}.jpg');
      setState(() {});
      downloadManager.getDownload(message.text);
    }
  }

  getImageSize(MessageModel message) {
    if (message.imageHeight > message.imageWidth) {
      if (message.imageHeight >= widget.deviceSize.height * 0.5) {
        imageHeight = widget.deviceSize.height * 0.5;
        var s = message.imageHeight - imageHeight;
        var realSize = s / message.imageHeight;
        imageWidth = message.imageWidth * (1 - realSize);
      } else {
        if (message.imageWidth >= widget.deviceSize.width * 0.5) {
          imageWidth = widget.deviceSize.width * 0.5;
          var s = message.imageWidth - imageWidth;
          var realSize = s / message.imageWidth;
          imageHeight = message.imageHeight * (1 - realSize);
        } else {
          imageWidth = message.imageWidth;
          imageHeight = message.imageHeight;
        }
      }
    } else {
      if (message.imageWidth >= widget.deviceSize.width * 0.6) {
        imageWidth = widget.deviceSize.width * 0.6;
        var s = message.imageWidth - imageWidth;
        var realSize = s / message.imageWidth;
        imageHeight = message.imageHeight * (1 - realSize);
      } else {
        if (message.imageHeight >= widget.deviceSize.height * 0.5) {
          imageHeight = widget.deviceSize.height * 0.5;
          var s = message.imageHeight - imageHeight;
          var realSize = s / message.imageHeight;
          imageWidth = message.imageWidth * (1 - realSize);
        } else {
          imageWidth = message.imageWidth;
          imageHeight = message.imageHeight;
        }
      }
    }
  }
}
