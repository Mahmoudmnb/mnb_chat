import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mnb_chat/featurs/chat/presentaion/pages/loading_page.dart';

import 'freind_tile.dart';

class FriendList extends StatelessWidget {
  final double deviceHeight;
  final Stream<QuerySnapshot<Map<String, dynamic>>> data;
  final String currentFriendNum;

  const FriendList({
    Key? key,
    required this.deviceHeight,
    required this.data,
    required this.currentFriendNum,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: deviceHeight * 0.9,
      child: Center(
        child: PageView(children: [
          StreamBuilder(
              stream: data,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding:
                              const EdgeInsets.only(top: 2, left: 2, right: 2),
                          child: FriendTile(
                          friendEmail:  snapshot.data!.docs[0].data()['to'],
                              nameLetters: getNameLetters(
                                  snapshot.data!.docs[index].data()['toName']),
                              snapshot: snapshot,
                              index: index,
                              currentFriendNum: currentFriendNum));
                    },
                  );
                } else {
                  return Center(
                    child: LoadingPage(
                        fullWidth: true,
                        deviceSize: MediaQuery.of(context).size),
                  );
                }
              }),
        ]),
      ),
    );
  }
}

String getNameLetters(String name) {
  var splitedName = name.split(' ');
  var f = splitedName.length == 1
      ? splitedName.first.characters.first
      : splitedName.first.characters.first + splitedName.last.characters.first;
  return f.toUpperCase();
}
