import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../auth/presentaion/pages/auth_page.dart';
import '../../providers/home_provider.dart';

class HomePageDrawer extends StatelessWidget {
  const HomePageDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          TextButton(
              onPressed: () async {
                SharedPreferences db = await SharedPreferences.getInstance();
                db.remove('currentUser');
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const AuthPage(),
                ));
              },
              child: const Text('LOG OUT')),
          TextButton(
              onPressed: () async {
                if (context.read<HomeProvider>().themeMode == ThemeMode.light) {
                  context.read<HomeProvider>().setThemeMode = ThemeMode.dark;
                } else {
                  context.read<HomeProvider>().setThemeMode = ThemeMode.light;
                }
              },
              child: const Text('change theme')),
        ],
      ),
    );
  }
}
