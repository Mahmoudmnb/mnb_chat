import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mnb_chat/core/app_theme.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constant.dart';
import '../../../../auth/models/user_model.dart';
import '../../pages/chat_page.dart';
import '../../pages/loading_page.dart';
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
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(top: 2, left: 2, right: 2),
                    child: ListTile(
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.background)),
                      trailing: snapshot.data!.docs.isNotEmpty
                          ? StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('messages')
                                  .doc(snapshot.data!.docs[index]
                                      .data()['chatId'])
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
                                            horizontal: 10, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .background,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Text(
                                          (snapshot1.data?.docs.length)
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
                      leading: Container(
                        alignment: Alignment.center,
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: AppTheme.nameColors[getNameLetters(snapshot
                                    .data!.docs[index]
                                    .data()['name'])[0]] ??
                                Colors.cyan,
                            shape: BoxShape.circle),
                        child: snapshot.data!.docs[0].data()['ImgUrl'] == null
                            ? Text(
                                getNameLetters(
                                    snapshot.data!.docs[index].data()['name']),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(500),
                                child: CachedNetworkImage(
                                    imageUrl: Constant.currentUsre.imgUrl!),
                              ),
                      ),
                      tileColor: Theme.of(context).colorScheme.onBackground,
                      title: Text(
                        snapshot.data!.docs[index].data()['name'],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.titleLarge!.color,
                            fontWeight: FontWeight.bold,
                            fontSize: deviceSize.width * 0.06),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: LoadingPage(
                      fullWidth: true, deviceSize: MediaQuery.of(context).size),
                );
        });
  }

  String getNameLetters(String name) {
    var splitedName = name.split(' ');
    var f = splitedName.length == 1
        ? splitedName.first.characters.first
        : splitedName.first.characters.first +
            splitedName.last.characters.first;
    return f.toUpperCase();
  }
}
