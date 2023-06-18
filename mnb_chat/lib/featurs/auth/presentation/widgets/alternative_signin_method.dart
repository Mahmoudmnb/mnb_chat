import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../provider/auth_provider.dart';

class AlternativeSignInMethod extends StatelessWidget {
  const AlternativeSignInMethod({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ToastContext toastContext = ToastContext();
    toastContext.init(context);
    return !context.watch<AuthProvider>().isLoding
        ? Row(
            children: [
              imageContainer('Google', context),
              imageContainer('Facebook', context),
              imageContainer('Twitter', context),
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }

  InkWell imageContainer(String type, BuildContext context) {
    return InkWell(
      onTap: () async {},
      child: Container(
        margin: const EdgeInsets.only(right: 20, top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          type == 'Google'
              ? MdiIcons.google
              : type == 'Facebook'
                  ? MdiIcons.facebook
                  : MdiIcons.twitter,
          size: 50,
          color: type == 'Google'
              ? Colors.redAccent
              : type == 'Facebook'
                  ? Colors.blue
                  : Colors.teal,
        ),
      ),
    );
  }
}

Future<dynamic> showPasswordDialog(BuildContext context) {
  TextEditingController controller = TextEditingController();
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        'Enter password',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
      ),
      content: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(5),
          height: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Theme.of(context).primaryColor)),
          child: TextField(
            keyboardType: TextInputType.visiblePassword,
            controller: controller,
            decoration: const InputDecoration.collapsed(hintText: 'Password'),
          )),
      alignment: Alignment.center,
      actions: [
        Center(
          child: TextButton(
              onPressed: () {
                if (controller.text.length >= 6) {
                  Navigator.pop(context, controller.text);
                } else {
                  Toast.show('passwrd maust be six character at least',
                      duration: 3);
                }
              },
              child: const Text(
                'Enter',
                style: TextStyle(fontSize: 20),
              )),
        )
      ],
    ),
  );
}
