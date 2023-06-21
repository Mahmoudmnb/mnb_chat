import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mnb_chat/featurs/chat/presentaion/providers/home_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constant.dart';
import '../../../../auth/models/user_model.dart';
import '../../pages/chat_page.dart';
import '../../providers/chat_provider.dart';

class FriendTile extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot;
  final int index;
  final String currentFriendNum;

  const FriendTile(
      {Key? key,
      required this.snapshot,
      required this.index,
      required this.currentFriendNum})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    ChatProvider chatReadContext = context.read<ChatProvider>();
    HomeProvider homeReadContext = context.read<HomeProvider>();

    onTabFreinTile() async {
      if (context.read<HomeProvider>().enableListTile) {
        context.read<HomeProvider>().setEnableListTile = false;
        Map<String, dynamic> map = {
          'token': snapshot.data!.docs[index].data()['toName'] ==
                  Constant.currentUsre.name
              ? snapshot.data!.docs[index].data()['fromToken']
              : snapshot.data!.docs[index].data()['toToken'],
          'name': snapshot.data!.docs[index].data()['toName'] ==
                  Constant.currentUsre.name
              ? snapshot.data!.docs[index].data()['fromName']
              : snapshot.data!.docs[index].data()['toName'],
          'email': snapshot.data!.docs[index].data()['to'] ==
                  Constant.currentUsre.email
              ? snapshot.data!.docs[index].data()['from']
              : snapshot.data!.docs[index].data()['to'],
        };
        chatReadContext.friend = UserModel.fromJson(map);
        String chatId = await chatReadContext.createChat();
        homeReadContext.setCurrentFriendNum = map['email'];
        Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (context) =>
              ChatePage(chatId: chatId, friend: UserModel.fromJson(map)),
        ))
            .then((value) {
          homeReadContext.setEnableListTile = true;
          homeReadContext.setCurrentFriendNum = '';
        });
      }
    }

    return ListTile(
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.background)),
      trailing: snapshot.data!.docs.isNotEmpty
          ? StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(snapshot.data!.docs[index].data()['chatId'])
                  .collection('msg')
                  .where('to', isEqualTo: Constant.currentUsre.email)
                  .where('isReseved', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot1) {
                return snapshot1.data != null && snapshot1.data!.docs.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text((snapshot1.data?.docs.length).toString(),
overflow: TextOverflow.ellipsis,
                        
                        ),
                      )
                    : const SizedBox.shrink();
              },
            )
          : const SizedBox.shrink(),
      onTap: onTabFreinTile,
      leading: CircleAvatar(
        backgroundColor: Colors.pinkAccent[100],
      ),
      tileColor: context.watch<HomeProvider>().themeMode == ThemeMode.dark
          ? Colors.grey.shade900
          : Colors.white,
      title: Text(
        snapshot.data!.docs[index].data()['toName'].toString(),
overflow: TextOverflow.ellipsis,

        style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge!.color,
            fontWeight: FontWeight.bold,
            fontSize: deviceSize.width * 0.06),
      ),
    );
  }
}
