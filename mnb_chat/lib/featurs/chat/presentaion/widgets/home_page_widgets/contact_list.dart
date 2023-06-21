// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constant.dart';
import '../../../../auth/models/user_model.dart';
import '../../pages/chat_page.dart';
import '../../providers/chat_provider.dart';
import '../../providers/home_provider.dart';

// ignore: must_be_immutable
class ContactList extends StatelessWidget {
  String currentFriendNum;
  ContactList({
    Key? key,
    required this.currentFriendNum,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    onTabFreinTile(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        index) async {
      if (context.read<HomeProvider>().enableListTile) {
        context.read<HomeProvider>().setEnableListTile = false;
        UserModel friend =
            UserModel.fromJson(snapshot.data!.docs[index].data());
        context.read<ChatProvider>().friend = friend;
        String chatId = await context.read<ChatProvider>().createChat();
        currentFriendNum = friend.email;
        Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (context) => ChatePage(
              chatId: chatId,
              friend: UserModel.fromJson(snapshot.data!.docs[index].data())),
        ))
            .then((value) {
          context.read<HomeProvider>().setEnableListTile = true;
          return currentFriendNum = '';
        });
      }
    }

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('email', isNotEqualTo: Constant.currentUsre.email)
            .snapshots(),
        builder: (context, snapshot) => snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: ListTile(
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.background)),
                    trailing: snapshot.data!.docs.isNotEmpty
                        ? StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('messages')
                                .doc(
                                    snapshot.data!.docs[index].data()['chatId'])
                                .collection('msg')
                                .where('to',
                                    isEqualTo: Constant.currentUsre.email)
                                .where('isReseved', isEqualTo: false)
                                .snapshots(),
                            builder: (context, snapshot1) {
                              return snapshot1.data != null &&
                                      snapshot1.data!.docs.isNotEmpty
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Text((snapshot1.data?.docs.length)
                                          .toString(),
overflow: TextOverflow.ellipsis,
                                          
                                          ),
                                    )
                                  : const SizedBox.shrink();
                            },
                          )
                        : const SizedBox.shrink(),
                    onTap: () {
                      onTabFreinTile(snapshot, index);
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.pinkAccent[100],
                    ),
                    tileColor: context.watch<HomeProvider>().themeMode ==
                            ThemeMode.dark
                        ? Colors.grey.shade900
                        : Colors.white,
                    title: Text(
                      snapshot.data!.docs[index].data()['name'],
overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge!.color,
                          fontWeight: FontWeight.bold,
                          fontSize: deviceSize.width * 0.06),
                    ),
                  ),
                ),
              )
            : const Text('please wait',
overflow: TextOverflow.ellipsis,
            
            ));
  }
}
