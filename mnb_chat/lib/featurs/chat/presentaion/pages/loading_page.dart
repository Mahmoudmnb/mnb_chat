// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mnb_chat/featurs/chat/presentaion/providers/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class LoadingPage extends StatelessWidget {
  final Size deviceSize;
  final bool fullWidth;
  const LoadingPage({
    Key? key,
    required this.deviceSize,
    required this.fullWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shimmer(
          gradient: LinearGradient(
              colors: context.watch<HomeProvider>().themeMode == ThemeMode.dark
                  ? [Colors.grey, Colors.black]
                  : [Colors.grey, Colors.white]),
          child: SizedBox(
            width: deviceSize.width,
            height: deviceSize.height,
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                var w =
                    100 + Random().nextInt((deviceSize.width * 0.5).toInt());
                return Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: fullWidth ? deviceSize.width : w + 0.0,
                    height: 50,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                );
              },
            ),
          )),
    );
  }
}
