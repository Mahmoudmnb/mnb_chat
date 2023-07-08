// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mnb_chat/core/constant.dart';

import '../provider/auth_provider.dart';
import 'hide_item.dart';

class AuthForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final getHeightOfKeyboard;
  const AuthForm({
    Key? key,
    required this.formKey,
    required this.getHeightOfKeyboard,
  }) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  String name = '';
  String password = '';
  String email = '';
  late TextEditingController nameCon;
  late TextEditingController passwordCon;
  late TextEditingController emailCon;
  @override
  void initState() {
    nameCon = TextEditingController();
    emailCon = TextEditingController();
    passwordCon = TextEditingController();
    context.read<AuthProvider>().colorOfEmailValidateIcon = Colors.black;
    super.initState();
  }

  @override
  void dispose() {
    nameCon.dispose();
    passwordCon.dispose();
    emailCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
          key: widget.formKey,
          child: Column(
            children: [
              const SizedBox(height: 5),
              HideItem(
                visabl: !context.watch<AuthProvider>().isSignIn,
                maxHight: 78,
                child: _createTextFormField('User name', context),
              ),
              const SizedBox(height: 15),
              _createTextFormField('E-mail adress', context),
              const SizedBox(height: 15),
              _createTextFormField('Password', context),
            ],
          )),
    );
  }

  TextFormField _createTextFormField(String label, BuildContext context) {
    return TextFormField(
      controller: label == 'Password'
          ? passwordCon
          : label == 'E-mail adress'
              ? emailCon
              : nameCon,
      keyboardType: label == 'Password'
          ? TextInputType.text
          : label == 'E-mail adress'
              ? TextInputType.emailAddress
              : TextInputType.name,
      obscureText:
          label == 'Password' && !Provider.of<AuthProvider>(context).visibl!
              ? true
              : false,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        errorStyle: const TextStyle(color: Colors.red),
        focusedErrorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red)),
        errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red)),
        labelStyle: const TextStyle(color: Colors.black),
        suffixIcon: label == 'Password'
            ? IconButton(
                icon: Icon(Provider.of<AuthProvider>(context).visibl!
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false)
                      .visableChangeSatate();
                })
            : label == 'E-mail adress'
                ? Icon(
                    Icons.check_circle_outline,
                    color:
                        context.watch<AuthProvider>().colorOfEmailValidateIcon,
                  )
                : null,
        suffixIconColor: Colors.black,
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade500)),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      validator: (value) {
        if (label == 'E-mail adress') {
          if ((value!.isEmpty ||
              !value.contains('@') ||
              !value.contains('.com'))) {
            return 'invalid email';
          }
        } else if (label == 'Password') {
          if (value!.isEmpty || value.length < 6) {
            return 'password must be six characters at least ';
          }
        } else if (!context.read<AuthProvider>().isSignIn) {
          if (value!.isEmpty || value.length < 6) {
            return 'user must be six characters at least ';
          }
        }
        return null;
      },
      onChanged: (value) async {
        if (label == 'E-mail adress') {
          Constant.heightOfKeyboard =
              (MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.of(context).viewPadding.bottom);
          print(Constant.heightOfKeyboard);
          SharedPreferences db = await SharedPreferences.getInstance();
          db.setDouble('heightOfKeyBoard', Constant.heightOfKeyboard);
        }
        label == 'E-mail adress'
            ? context.read<AuthProvider>().onTextEmailChange(value)
            : null;
      },
      onSaved: (newValue) {
        label == 'Password'
            ? context.read<AuthProvider>().setPassword = newValue!
            : label == 'E-mail adress'
                ? context.read<AuthProvider>().setEmail = newValue!
                : context.read<AuthProvider>().setName = newValue!;
      },
    );
  }
}
