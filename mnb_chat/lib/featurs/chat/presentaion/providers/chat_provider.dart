// ignore_for_file: depend_on_referenced_packages, prefer_final_fields, unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constant.dart';
import '../../../auth/models/user_model.dart';
import '../../models/message.dart';

class ChatProvider extends ChangeNotifier {
  Map<String, int> numOfNewMessages = {};
  final Map<String, double> _imageProgressValue = {};
  get imgeProgressValue => _imageProgressValue;

  String emojiText = '';
  bool checkBoxKey = false;
  bool isReplied = false;
  bool isConvertedMode = false;

  bool _editMode = false;
  get editMode => _editMode;

  String? _inputText = '';
  get inputText => _inputText;
  set setConvertedMode(bool value) {
    isConvertedMode = value;
    notifyListeners();
  }

  set setInputText(String value) {
    _inputText = value;
    notifyListeners();
  }

  set setEditMode(bool value) {
    _editMode = value;
    notifyListeners();
  }

  UserModel? friend;

//!                     **********************************       variabels      ***************************************************
  //* this is controllers for textEditing and listView
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();

  //* this variable for controlling emoji piker

  bool _showImojiPicker = false;
  get showImojiPicker => _showImojiPicker;
  set setShowImpjiPicker(bool value) {
    _showImojiPicker = value;
    notifyListeners();
  }

  //* this variable for detecting if the appBar is mianAppBar or edit/delete/....etc
  bool _isMainAppBar = true;
  get isMainAppBar => _isMainAppBar;
  set setMainAppBar(bool value) {
    _isMainAppBar = value;
    notifyListeners();
  }

  //* this is for focuseNode of input text field in the chat screen
  FocusNode focusNode = FocusNode(debugLabel: 'mnb');
  //* this for selected messages for delete or edit or copy message or  .... etc
  List<bool> selectedMessages = [];
  void setSelectedMessags(bool value, int index) {
    selectedMessages[index] = value;
    notifyListeners();
  }

  //* this is for fromMe selected messages and toMe selected messages
  List<MessageModel> fromMeSelectedMessage = [];
  List<MessageModel> toMeSelectedMessage = [];
  //* this is a total selected messages for copy
  List<MessageModel> copiedMessages = [];
  //* this is the selected message for edit or .....
  MessageModel? selectedMessage;

//!                     ***************************    functions   **************************************

//* detect what back button should do
  Future<bool> willPopScopeOnTab() async {
    if (!isMainAppBar) {
      setMainAppBar = true;
      selectedMessages = [];
      fromMeSelectedMessage = [];
      toMeSelectedMessage = [];
      setShowImpjiPicker = false;
      return Future.value(false);
    } else if (editMode) {
      setShowImpjiPicker = false;
      _editMode = false;
      controller.text = '';
      selectedMessages = [];
      fromMeSelectedMessage = [];
      toMeSelectedMessage = [];
      return Future.value(false);
    } else if (isReplied) {
      cancelReplyModeOnTab();
      return Future.value(false);
    }
    if (showImojiPicker) {
      setShowImpjiPicker = false;
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

//* when you type on emoji picker
  onEmojiSelected(category) {
    //* this is for moving cursor to end of textField
    controller.value = TextEditingValue(
      text: controller.text,
      selection: TextSelection.collapsed(offset: controller.text.length),
    );
    setInputText = controller.text;
    notifyListeners();
  }

//* when click on emoji icon to open emoji picker
  emojiOnTab(BuildContext context) {
    if (!showImojiPicker) {
      FocusScope.of(context).unfocus();
      setShowImpjiPicker = !showImojiPicker;
    } else {
      FocusScope.of(context).requestFocus(focusNode);
      Timer.periodic(const Duration(seconds: 1), (timer) {
        setShowImpjiPicker = !showImojiPicker;
        timer.cancel();
      });
    }
    notifyListeners();
  }

  //* to delete a message or Image

  deleteOnTab(chatId, context, freind) async {
    for (var element in toMeSelectedMessage) {
      var selectedMessage = FirebaseFirestore.instance
          .collection('messages')
          .doc(chatId)
          .collection('msg')
          .doc(element.messageId);
      var s = await selectedMessage.get();
      if (s.data()!['deletedFrom'] == null) {
        await selectedMessage
            .update({'deletedFrom': Constant.currentUsre.phoneNamber});
      } else {
        await selectedMessage.delete();
        if (element.type == 'Image') {
          await FirebaseStorage.instance
              .ref('chat')
              .child(element.messageId)
              .delete();
          if (element.reciverPath != null) {
            File imageFile = File(element.reciverPath!);
            await imageFile.delete();
          }
        }
      }
    }
    if (fromMeSelectedMessage.isNotEmpty) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text(
                  'Delete message',
                  style: TextStyle(fontSize: 25),
                ),
                content: SizedBox(
                  height: 86,
                  child: Column(
                    children: [
                      const Text(
                        'Do you realy want to delete this message ?',
                        style: TextStyle(fontSize: 15),
                      ),
                      StatefulBuilder(
                        builder: (context, setState) => Row(
                          children: [
                            Checkbox(
                              activeColor: Theme.of(context).colorScheme.error,
                              value: checkBoxKey,
                              onChanged: (value) {
                                setState(
                                  () => checkBoxKey = value!,
                                );
                              },
                            ),
                            Text(
                              'delete also from ${friend!.name} ?',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(checkBoxKey);
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 20),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 20),
                      ))
                ],
              )).then((value) async {
        if (value != null) {
          for (var element in fromMeSelectedMessage) {
            var selectedMessage = FirebaseFirestore.instance
                .collection('messages')
                .doc(chatId)
                .collection('msg')
                .doc(element.messageId);
            if (value == true) {
              await selectedMessage.delete();
              if (element.type == 'Image') {
                await FirebaseStorage.instance
                    .ref('chat')
                    .child(element.messageId)
                    .delete();
                if (element.senderPath != null) {
                  File imageFile = File(element.senderPath!);
                  await imageFile.delete();
                }
              }
            } else {
              var s = await selectedMessage.get();
              if (s.data()!['deletedFrom'] == null) {
                await selectedMessage
                    .update({'deletedFrom': Constant.currentUsre.phoneNamber});
              } else {
                await selectedMessage.delete();
                if (element.type == 'Image') {
                  await FirebaseStorage.instance
                      .ref('chat')
                      .child(element.messageId)
                      .delete();
                  if (element.senderPath != null) {
                    File imageFile = File(element.senderPath!);
                    await imageFile.delete();
                  }
                }
              }
            }
          }
        }
        fromMeSelectedMessage = [];
      });
    }
    setMainAppBar = true;
    selectedMessages = [];
    toMeSelectedMessage = [];
  }

//* when click on message to select  or disSelect
  onTabMessage(int index, bool isme, MessageModel message, context) {
    if (!isMainAppBar) {
      if (selectedMessages[index]) {
        setSelectedMessags(false, index);
        isme
            ? fromMeSelectedMessage.removeWhere(
                (element) => element.messageId == message.messageId)
            : toMeSelectedMessage.removeWhere(
                (element) => element.messageId == message.messageId);
        copiedMessages.remove(message);
      } else {
        copiedMessages.add(message);
        selectedMessage = isme ? message : null;
        isme
            ? fromMeSelectedMessage.add(message)
            : toMeSelectedMessage.add(message);
        setSelectedMessags(true, index);
      }
      if (!selectedMessages.contains(true)) {
        setMainAppBar = true;
      }
    } else {
      setShowImpjiPicker = false;
      FocusScope.of(context).unfocus();
    }
  }

//* when long press on message or image to selected and switch appBar to edit and delete and... etc mode
  onLongPressMessage(MessageModel message, bool isme, int index, int lenght) {
    if (isMainAppBar && !editMode) {
      checkBoxKey = false;
      copiedMessages = [];
      fromMeSelectedMessage = [];
      toMeSelectedMessage = [];
      copiedMessages.add(message);
      setSelectedMessags(true, index);
      selectedMessage = message;
      setMainAppBar = false;
      isme
          ? fromMeSelectedMessage.add(message)
          : toMeSelectedMessage.add(message);
    }
  }

  //* when click on send icon to send or edit some messages
  editOrSendOnTab(String chatId, UserModel friend) async {
    if (editMode) {
      var newText = controller.text;
      controller.text = '';
      fromMeSelectedMessage = [];
      toMeSelectedMessage = [];
      selectedMessages = [];
      emojiText = '';
      setEditMode = false;
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(chatId)
          .collection('msg')
          .doc(selectedMessage!.messageId)
          .update({'text': newText});
    } else {
      if (controller.text.isNotEmpty) {
        String id = generateId();
        MessageModel message = MessageModel(
            type: 'Message',
            isreplied: isReplied,
            repliedText: isReplied ? selectedMessage!.text : null,
            fromName: Constant.currentUsre.name,
            messageId: id,
            text: controller.text,
            date: Timestamp.now(), // FieldValue.serverTimestamp(),
            from: Constant.currentUsre.phoneNamber,
            to: friend.phoneNamber);
        cancelReplyModeOnTab();
        sendPushMessage(
            controller.text,
            Constant.currentUsre.name,
            friend.token,
            Constant.currentUsre.phoneNamber,
            chatId,
            Constant.currentUsre);
        controller.text = '';
        _inputText = '';
        emojiText = '';
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(chatId)
            .collection('msg')
            .doc(id)
            .set(message.toMap())
            .then((value) async {
          await FirebaseFirestore.instance
              .collection('messages')
              .doc(chatId)
              .collection('msg')
              .doc(id)
              .update({'isSent': true});
        });
        moveToEnd();
      }
    }
    notifyListeners();
  }

  //* this is for sending notification to other user
  void sendPushMessage(String body, String title, String token,
      String senderNum, String chatId, UserModel localFreind) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAApisdxjw:APA91bGy4m2H8sUXgHbDIuof13KaMqTjapWYf15Gcmd1-Z1xeA3Y858rUaoojcGh6lii9-p9wS6aMacQgxzVYqK9-bFPpQyf7QfrlgNOyyhkEFMM6_1iFyFMX_rHp1FZiq7gHf76IbJA'
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
              'android_channel_id': 'dbfood'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': 0,
              'status': 'done',
              'senderNum': senderNum,
              'chatId': chatId,
              'friend': localFreind
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
  }
//* this is for picking Image from gallery

  Future<File?> pickImage() async {
    var r = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (r != null) {
      return File(r.path);
    } else {
      return null;
    }
  }

//* this is for sending an image
  uploadImage(String chatId, File pickedImage) async {
    String id = generateId();
    var decodedImage = await decodeImageFromList(pickedImage.readAsBytesSync());
    MessageModel message = MessageModel(
        imageHeight: decodedImage.height * 1.0,
        imageWidth: decodedImage.width * 1.0,
        senderPath: pickedImage.path,
        type: 'Image',
        isreplied: isReplied,
        repliedText: isReplied ? selectedMessage!.text : null,
        fromName: Constant.currentUsre.name,
        messageId: id,
        text: '',
        date: Timestamp.now(),
        from: Constant.currentUsre.phoneNamber,
        to: friend!.phoneNamber);
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('msg')
        .doc(id)
        .set(message.toMap());
    var comImage = await FlutterImageCompress.compressAndGetFile(
        pickedImage.absolute.path, '${Constant.localPath!.path}$id.jpg');
    File pickeImageFile = File(comImage!.path);
    FirebaseStorage.instance
        .ref('chat')
        .child(id)
        .putFile(pickeImageFile)
        .snapshotEvents
        .listen((event) async {
      if (event.state == TaskState.success) {
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(chatId)
            .collection('msg')
            .doc(id)
            .update({'isSent': true, 'text': await event.ref.getDownloadURL()});
        sendPushMessage('Image', Constant.currentUsre.name, friend!.token,
            Constant.currentUsre.phoneNamber, chatId, friend!);
        _imageProgressValue[id] = 0;
      }
    });
    moveToEnd();
    notifyListeners();
  }

  //* this is for moving to the end of the messages when send an new message
  void moveToEnd() {
    scrollController.animateTo(scrollController.position.minScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  //* this is for generating a unique id
  String generateId() {
    return const Uuid().v1();
  }

  //* this is a method for cancel icons in alternative appBar to return to main appBar and disSelect messages
  cancelOnTab() {
    setMainAppBar = true;
    selectedMessages = [];
    fromMeSelectedMessage = [];
    toMeSelectedMessage = [];
  }

  Future<String> createChat() async {
    var first = await FirebaseFirestore.instance
        .collection('messages')
        .where('to', isEqualTo: Constant.currentUsre.phoneNamber)
        .where('from', isEqualTo: friend!.phoneNamber)
        .get();
    var second = await FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: Constant.currentUsre.phoneNamber)
        .where('to', isEqualTo: friend!.phoneNamber)
        .get();
    if (first.docs.isEmpty && second.docs.isEmpty) {
      var chatId = await FirebaseFirestore.instance.collection('messages').add({
        'fromToken': Constant.currentUsre.token,
        'toToken': friend!.token,
        'from': Constant.currentUsre.phoneNamber,
        'fromName': Constant.currentUsre.name,
        'toName': friend!.name,
        'to': friend!.phoneNamber
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(Constant.currentUsre.phoneNamber)
          .collection('friends')
          .doc(friend!.phoneNamber)
          .set({
        'to': friend!.phoneNamber,
        'toToken': friend!.token,
        'toName': friend!.name,
        'chatId': chatId.id
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(friend!.phoneNamber)
          .collection('friends')
          .doc(Constant.currentUsre.phoneNamber)
          .set({
        'to': Constant.currentUsre.phoneNamber,
        'toToken': Constant.currentUsre.token,
        'toName': Constant.currentUsre.name,
        'chatId': chatId.id
      });
      return Future.value(chatId.id);
    } else {
      String chatId = '';
      if (first.docs.isNotEmpty) {
        chatId = first.docs.first.id;
      } else {
        chatId = second.docs.first.id;
      }
      FirebaseFirestore.instance
          .collection('users')
          .doc(Constant.currentUsre.phoneNamber)
          .collection('friends')
          .doc(friend!.phoneNamber)
          .set({
        'to': friend!.phoneNamber,
        'toToken': friend!.token,
        'toName': friend!.name,
        'chatId': chatId,
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(friend!.phoneNamber)
          .collection('friends')
          .doc(Constant.currentUsre.phoneNamber)
          .set({
        'to': Constant.currentUsre.phoneNamber,
        'toToken': Constant.currentUsre.token,
        'toName': Constant.currentUsre.name,
        'chatId': chatId
      });
      return chatId;
    }
  }

  Future<void> editOnTab(BuildContext context) async {
    //* open keyboard on edit
    _editMode = true;
    setMainAppBar = true;
    controller.value = TextEditingValue(
      text: selectedMessage!.text,
      selection: TextSelection.collapsed(offset: selectedMessage!.text.length),
    );
    setInputText = controller.text;
    FocusScope.of(context).requestFocus(focusNode);
  }

  copyOnTab() {
    String clipText = '';
    for (var element in copiedMessages) {
      clipText += element.text;
      clipText += '      \n';
    }
    Clipboard.setData(ClipboardData(text: clipText));
    setMainAppBar = true;
    selectedMessages = [];
    fromMeSelectedMessage = [];
    toMeSelectedMessage = [];
  }

  replyOnTab() {
    setMainAppBar = true;
    isReplied = true;
    selectedMessages = [];
    fromMeSelectedMessage = [];
    toMeSelectedMessage = [];
  }

  cancelReplyModeOnTab() {
    isReplied = false;
    notifyListeners();
  }

  convertMessageOnTab(BuildContext context) {
    isConvertedMode = true;
    setMainAppBar = true;
    selectedMessages = [];
    fromMeSelectedMessage = [];
    toMeSelectedMessage = [];
    Navigator.of(context).pop();
    notifyListeners();
  }

  sendConvertedMessage(String chatId) async {
    for (MessageModel element in copiedMessages) {
      var message = MessageModel(
          type: 'Message',
          fromName: element.fromName,
          messageId: element.messageId,
          text: element.text,
          date: Timestamp.now(),
          from: element.from,
          to: element.to);
      var s = await FirebaseFirestore.instance
          .collection('messages')
          .doc(chatId)
          .collection('msg')
          .add(message.toMap());
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(chatId)
          .collection('msg')
          .doc(s.id)
          .update({'messageId': s.id, 'isSent': true});
      moveToEnd();
    }
    isConvertedMode = false;

    notifyListeners();
  }

  imgageProgressDownload(double progress, String imageId) {
    _imageProgressValue[imageId] = progress;
    notifyListeners();
  }

  onDoneImageDownlad(String imageId) {
    _imageProgressValue.remove(imageId);
    notifyListeners();
  }
}
