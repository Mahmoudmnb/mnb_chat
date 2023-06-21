import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
                          padding: const EdgeInsets.only(
                              top: 10, left: 10, right: 10),
                          child: FriendTile(
                              snapshot: snapshot,
                              index: index,
                              currentFriendNum: currentFriendNum));
                    },
                  );
                } else {
                  return const Text('please  wait',
overflow: TextOverflow.ellipsis,
                  
                  );
                }
              }),
        ]),
      ),
    );
  }
}
