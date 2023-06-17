import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constant.dart';
import '../widgets/auth_card.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> getHeightOfKeyBoard() async {
      if (Constant.heightOfKeyboard == 0) {
        SharedPreferences db = await SharedPreferences.getInstance();
        var h = MediaQuery.of(context).viewInsets.bottom;
        db.setDouble('heightOfKeyBoard', h);
        Constant.heightOfKeyboard = h;
        print(h);
      }
    }

    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: InkWell(
        onTap: () async {},
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              child: Container(
                alignment: Alignment.center,
                height: deviceSize.height * 0.7,
                width: deviceSize.width,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50)),
                    color: Color.fromARGB(255, 233, 203, 213)),
              ),
            ),
            Align(
                alignment: const Alignment(0, 0),
                child: AuthCard(
                  fun: getHeightOfKeyBoard,
                ))
          ],
        ),
      ),
    );
  }
}
