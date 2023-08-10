import 'package:curved_navigation_bar_with_label/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mnb_chat/featurs/chat/presentaion/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class BottomNavigation extends StatelessWidget {
  final PageController pageController;
  const BottomNavigation({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
        index: context.watch<ChatProvider>().selectedPage,
        onTap: (value) {
          context.read<ChatProvider>().setSelectedPage = value;
          context.read<ChatProvider>().pageController.animateToPage(value,
              duration: const Duration(milliseconds: 500),
              curve: Curves.linear);
        },
        backgroundColor: Theme.of(context).colorScheme.onBackground,
        color: Theme.of(context).textTheme.titleLarge!.color,
        buttonBackgroundColor: const Color.fromARGB(255, 207, 194, 194),
        items: [
          CurvedNavigationBarItem(
              icon: Icon(
                Icons.chat,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
              label: 'Chat'),
          CurvedNavigationBarItem(
              icon: Icon(
                Icons.people,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
              label: 'People'),
          CurvedNavigationBarItem(
              icon: Icon(
                MdiIcons.faceManProfile,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
              label: 'Profile'),
        ]);
  }
}
