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
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constant.dart';
import '../../../auth/models/user_model.dart';
import '../../models/message.dart';
import 'home_provider.dart';

class ChatProvider extends ChangeNotifier {
//!                     **********************************       variabels      ***************************************************
  //* this is an opject of the user whom i'm chatting with him
  UserModel? friend;

  //* this is to know if its a new message in the textFild or edit message
  bool _editMode = false;
  get editMode => _editMode;
  set setEditMode(bool value) {
    _editMode = value;
    notifyListeners();
  }

  //* this is  to know if there are a text in the text field or if its empty
  String? _inputText = '';
  get inputText => _inputText;
  set setInputText(String value) {
    _inputText = value;
    notifyListeners();
  }

  //* this is for alertDialog in delete message checkBox
  bool checkBoxKey = false;
  //* this is to know if there a converted message or not

  bool isConvertedMode = false;
  set setConvertedMode(bool value) {
    isConvertedMode = value;
    notifyListeners();
  }

  //* this is to know if there a replied message or not
  bool isReplied = false;

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

  deleteOnTab(chatId, context, freind, double hightOfDevice,
      double widthOfDevice) async {
    for (var element in toMeSelectedMessage) {
      var selectedMessage = FirebaseFirestore.instance
          .collection('messages')
          .doc(chatId)
          .collection('msg')
          .doc(element.messageId);
      var s = await selectedMessage.get();
      if (s.data()!['deletedFrom'] == null) {
        await selectedMessage
            .update({'deletedFrom': Constant.currentUsre.email});
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
                backgroundColor:
                    context.watch<HomeProvider>().themeMode == ThemeData.light()
                        ? Colors.black
                        : Colors.white,
                title: Text(
                  'Delete message',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: widthOfDevice * 0.08,
                    color: context.watch<HomeProvider>().themeMode ==
                            ThemeData.light()
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                content: SizedBox(
                  height: hightOfDevice * 0.1,
                  child: Column(
                    children: [
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
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: widthOfDevice * 0.04,
                                color:
                                    context.watch<HomeProvider>().themeMode ==
                                            ThemeData.light()
                                        ? Colors.white
                                        : Colors.black,
                              ),
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
                      child: Text(
                        'Delete',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: widthOfDevice * 0.05,
                          color: context.watch<HomeProvider>().themeMode ==
                                  ThemeData.light()
                              ? Colors.white
                              : Colors.black,
                        ),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      },
                      child: Text(
                        'Cancel',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: widthOfDevice * 0.05,
                          color: context.watch<HomeProvider>().themeMode ==
                                  ThemeData.light()
                              ? Colors.white
                              : Colors.black,
                        ),
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
                    .update({'deletedFrom': Constant.currentUsre.email});
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
            from: Constant.currentUsre.email,
            to: friend.email);
        cancelReplyModeOnTab();
        sendPushMessage(
            controller.text,
            Constant.currentUsre.name,
            friend.token,
            Constant.currentUsre.email,
            chatId,
            Constant.currentUsre);
        controller.text = '';
        _inputText = '';
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
              'friend': localFreind,
              'token': token
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
      String id = generateId();
      File finalFile = await File(r.path)
          .copy('/data/user/0/com.example.mnb_chat/cache/$id.jpg');
      File(r.path).delete();
      return finalFile;
    } else {
      return null;
    }
  }

//* this is for sending an image
  uploadImage(String chatId, File pickedImage) async {
    String id = pickedImage.path.split('/').last.split('.').first;
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
        from: Constant.currentUsre.email,
        to: friend!.email);
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('msg')
        .doc(id)
        .set(message.toMap());
    var comImage = await FlutterImageCompress.compressAndGetFile(
        pickedImage.absolute.path, '${Constant.appPath!.path}$id.jpg');
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
            Constant.currentUsre.email, chatId, friend!);
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

  //* this is for generating a unique id for messages
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

  //* this is for creating a new chat with new friend or open an old chat
  Future<String> createChat() async {
    var first = await FirebaseFirestore.instance
        .collection('messages')
        .where('to', isEqualTo: Constant.currentUsre.email)
        .where('from', isEqualTo: friend!.email)
        .get();
    var second = await FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: Constant.currentUsre.email)
        .where('to', isEqualTo: friend!.email)
        .get();
    if (first.docs.isEmpty && second.docs.isEmpty) {
      var chatId = await FirebaseFirestore.instance.collection('messages').add({
        'fromToken': Constant.currentUsre.token,
        'toToken': friend!.token,
        'from': Constant.currentUsre.email,
        'fromName': Constant.currentUsre.name,
        'toName': friend!.name,
        'to': friend!.email
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(Constant.currentUsre.email)
          .collection('friends')
          .doc(friend!.email)
          .set({
        'to': friend!.email,
        'toToken': friend!.token,
        'toName': friend!.name,
        'chatId': chatId.id
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(friend!.email)
          .collection('friends')
          .doc(Constant.currentUsre.email)
          .set({
        'to': Constant.currentUsre.email,
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
          .doc(Constant.currentUsre.email)
          .collection('friends')
          .doc(friend!.email)
          .set({
        'to': friend!.email,
        'toToken': friend!.token,
        'toName': friend!.name,
        'chatId': chatId,
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(friend!.email)
          .collection('friends')
          .doc(Constant.currentUsre.email)
          .set({
        'to': Constant.currentUsre.email,
        'toToken': Constant.currentUsre.token,
        'toName': Constant.currentUsre.name,
        'chatId': chatId
      });
      return chatId;
    }
  }

  //* when click on edit icon in alternative appBar to edit a message
  Future<void> editOnTab(BuildContext context) async {
    //! open keyboard on edit
    FocusScope.of(context).requestFocus(focusNode);
    _editMode = true;
    setMainAppBar = true;
    controller.value = TextEditingValue(
      text: selectedMessage!.text,
      selection: TextSelection.collapsed(offset: selectedMessage!.text.length),
    );
    setInputText = controller.text;
  }

  //* when click on copy message in alternative appBar to copy messages
  copyOnTab() {
    String clipText = '';
    for (var element in copiedMessages) {
      clipText += element.text;
      clipText += '\n';
    }
    Clipboard.setData(ClipboardData(text: clipText));
    setMainAppBar = true;
    selectedMessages = [];
    fromMeSelectedMessage = [];
    toMeSelectedMessage = [];
  }

  //* when click on reply in alternative bottomSeet to reply a message
  replyOnTab() {
    setMainAppBar = true;
    isReplied = true;
    selectedMessages = [];
    fromMeSelectedMessage = [];
    toMeSelectedMessage = [];
  }
  //* when click on reply in alternative bottomSeet to cancel reply a message

  cancelReplyModeOnTab() {
    isReplied = false;
    notifyListeners();
  }
  //* when click on reply in alternative bottomSeet to convert  a message to another chat

  convertMessageOnTab(BuildContext context) {
    isConvertedMode = true;
    setMainAppBar = true;
    selectedMessages = [];
    fromMeSelectedMessage = [];
    toMeSelectedMessage = [];
    Navigator.of(context).pop();
    notifyListeners();
  }

  //* when click on reply in alternative bottomSeet to send converted  message to another chat
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

  uploadVoice(File voice, String id, String duration, String chatId) async {
    MessageModel message = MessageModel(
        duration: duration,
        senderPath: voice.path,
        type: 'Voice',
        isreplied: isReplied,
        repliedText: isReplied ? selectedMessage!.text : null,
        fromName: Constant.currentUsre.name,
        messageId: id,
        text: '',
        date: Timestamp.now(),
        from: Constant.currentUsre.email,
        to: friend!.email);
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('msg')
        .doc(id)
        .set(message.toMap());
    FirebaseStorage.instance
        .ref('chat')
        .child(id)
        .putFile(voice)
        .snapshotEvents
        .listen((event) async {
      if (event.state == TaskState.success) {
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(chatId)
            .collection('msg')
            .doc(id)
            .update({'isSent': true, 'text': await event.ref.getDownloadURL()});
        sendPushMessage('Voice', Constant.currentUsre.name, friend!.token,
            Constant.currentUsre.email, chatId, friend!);
      }
    });
    moveToEnd();
    notifyListeners();
  }
}
