import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_theme.dart';
import '../../../../../core/constant.dart';
import '../../../../auth/models/user_model.dart';
import '../../pages/chat_page.dart';
import '../../providers/chat_provider.dart';
import '../../providers/home_provider.dart';

class FriendTile extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot;
  final int index;
  final String currentFriendNum;
  final String nameLetters;
  FriendTile({
    Key? key,
    required this.snapshot,
    required this.index,
    required this.currentFriendNum,
    required this.nameLetters,
  }) : super(key: key) {}

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

    snapshot.data!.docs.forEach((element) {
      print(element.data()['toImage']);
    });
    return ListTile(
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
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
                  .snapshots(includeMetadataChanges: true),
              builder: (context, snapshot1) {
                return snapshot1.data != null && snapshot1.data!.docs.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).textTheme.titleLarge!.color,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          (snapshot1.data?.docs.length).toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.background),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            )
          : const SizedBox.shrink(),
      onTap: onTabFreinTile,
      leading: snapshot.data!.docs[index].data()['toImage'] == null
          ? Container(
              alignment: Alignment.center,
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  color: AppTheme.nameColors[nameLetters[0]] ?? Colors.cyan,
                  shape: BoxShape.circle),
              child: Text(
                nameLetters,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ))
          : SizedBox(
              height: 50,
              width: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(500),
                child: CachedNetworkImage(
                    errorWidget: (context, url, error) => Text(
                          nameLetters,
                          style: TextStyle(
                              fontSize: deviceSize.width * 0.08,
                              fontWeight: FontWeight.bold),
                        ),
                    progressIndicatorBuilder: (context, url, progress) =>
                        CircularProgressIndicator(),
                    imageUrl: snapshot.data!.docs[index].data()['toImage']),
              ),
            ),
      tileColor: Theme.of(context).colorScheme.onBackground,
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
