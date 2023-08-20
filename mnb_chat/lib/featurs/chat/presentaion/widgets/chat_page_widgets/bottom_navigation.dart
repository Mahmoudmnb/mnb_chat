import 'package:curved_navigation_bar_with_label/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';

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
              duration: const Duration(milliseconds: 50), curve: Curves.linear);
        },
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        color: Theme.of(context).textTheme.titleLarge!.color,
        buttonBackgroundColor: Theme.of(context).colorScheme.onBackground,
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
