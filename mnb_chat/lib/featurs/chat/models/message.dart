import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  int timeForSend;
  double imageHeight;
  double imageWidth;
  final String nameOfImage;
  bool isLonding;
  double progressDownloading;
  bool isDownloded;
  String? senderPath;
  String? reciverPath;
  final String fromName;
  final String text;
  final Timestamp date;
  final String from;
  final String to;
  final String messageId;
  final String type;
  String? deletedFrom;
  bool isreplied;
  String? repliedText;
  bool isSent;
  bool isReseved;

  MessageModel({
    this.timeForSend = 0,
    this.imageHeight = 0,
    this.imageWidth = 0,
    this.nameOfImage = '',
    this.progressDownloading = 0,
    this.isLonding = false,
    this.isDownloded = false,
    this.senderPath,
    this.reciverPath,
    required this.fromName,
    required this.text,
    required this.date,
    required this.from,
    required this.to,
    required this.messageId,
    required this.type,
    this.deletedFrom,
    this.isreplied = false,
    this.repliedText,
    this.isSent = false,
    this.isReseved = false,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'timeForSend': timeForSend,
      'imageHeight': imageHeight,
      'imageWidth': imageWidth,
      'nameOfImage': nameOfImage,
      'isLonding': isLonding,
      'progressDownloading': progressDownloading,
      'isDownloded': isDownloded,
      'senderPath': senderPath,
      'reciverPath': reciverPath,
      'fromName': fromName,
      'text': text,
      'date': date,
      'from': from,
      'to': to,
      'messageId': messageId,
      'type': type,
      'deletedFrom': deletedFrom,
      'isreplied': isreplied,
      'repliedText': repliedText,
      'isSent': isSent,
      'isReseved': isReseved,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      timeForSend: map['timeForSend'] ?? 0,
      imageHeight: map['imageHeight'] as double,
      imageWidth: map['imageWidth'] as double,
      nameOfImage: map['nameOfImage'] as String,
      isLonding: map['isLonding'] ?? false,
      progressDownloading: map['progressDownloading'] ?? 0,
      isDownloded: map['isDownloded'] as bool,
      senderPath:
          map['senderPath'] != null ? map['senderPath'] as String : null,
      reciverPath:
          map['reciverPath'] != null ? map['reciverPath'] as String : null,
      fromName: map['fromName'] as String,
      text: map['text'] as String,
      date: map['date'] as Timestamp,
      from: map['from'] as String,
      to: map['to'] as String,
      messageId: map['messageId'] as String,
      type: map['type'] as String,
      deletedFrom:
          map['deletedFrom'] != null ? map['deletedFrom'] as String : null,
      isreplied: map['isreplied'] as bool,
      repliedText:
          map['repliedText'] != null ? map['repliedText'] as String : null,
      isSent: map['isSent'] as bool,
      isReseved: map['isReseved'] as bool,
    );
  }
  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
