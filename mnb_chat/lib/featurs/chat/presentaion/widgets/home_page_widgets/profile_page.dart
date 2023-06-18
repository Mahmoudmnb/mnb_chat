import 'package:flutter/material.dart';
import 'package:mnb_chat/core/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../auth/presentaion/pages/auth_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.bottom +
            MediaQuery.of(context).padding.top);
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              height: deviceHeight * 0.3,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ],
        ),
        Positioned(
          top: deviceHeight * 0.06,
          left: deviceWidth * 0.1,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20)),
            width: deviceWidth * 0.8,
            height: deviceHeight * 0.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: deviceWidth * 0.3,
                  width: deviceWidth * 0.3,
                  decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.error.withOpacity(0.5),
                      shape: BoxShape.circle),
                ),
                const SizedBox(height: 20),
                Text(
                  Constant.currentUsre.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: deviceWidth * 0.05,
                      color: Theme.of(context).textTheme.titleLarge!.color),
                ),
                const SizedBox(height: 20),
                Text(
                  Constant.currentUsre.phoneNamber,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge!.color,
                      fontSize: deviceWidth * 0.04),
                )
              ],
            ),
          ),
        ),
        Positioned(
            bottom: 0,
            child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                height: deviceHeight * 0.45,
                width: deviceWidth,
                child: ListView(
                  children: [
                    ListTile(
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: Colors.transparent)),
                      tileColor: Theme.of(context).colorScheme.surface,
                      title: Text(
                        'Change image of the account',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge!.color,
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        child: Icon(
                          Icons.camera,
                          color: Theme.of(context).textTheme.titleLarge!.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: Colors.transparent)),
                      tileColor: Theme.of(context).colorScheme.surface,
                      title: Text(
                        'Update user name or naumber',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge!.color,
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        child: Icon(
                          Icons.update,
                          color: Theme.of(context).textTheme.titleLarge!.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      onTap: () async {
                        SharedPreferences db =
                            await SharedPreferences.getInstance();
                        db.remove('currentUser');
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const AuthPage(),
                        ));
                      },
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: Colors.transparent)),
                      tileColor: Theme.of(context).colorScheme.surface,
                      title: Text(
                        'Log out',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge!.color,
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        child: Icon(
                          Icons.exit_to_app,
                          color: Theme.of(context).textTheme.titleLarge!.color,
                        ),
                      ),
                    )
                  ],
                )))
      ]),
    );
  }
}
