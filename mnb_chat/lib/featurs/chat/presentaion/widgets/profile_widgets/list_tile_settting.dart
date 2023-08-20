import 'package:flutter/material.dart';

class ListTileSetting extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function() onTap;
  final double deviceWidth;
  const ListTileSetting({
    Key? key,
    required this.text,
    required this.icon,
    required this.onTap,
    required this.deviceWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.transparent)),
      tileColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
      title: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge!.color,
            fontSize: deviceWidth * 0.05,
            fontWeight: FontWeight.bold),
      ),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          icon,
          color: Theme.of(context).textTheme.titleLarge!.color,
        ),
      ),
    );
  }
}
