import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'hide_item.dart';
import '../provider/auth_provider.dart';

class AuthForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const AuthForm({Key? key, required this.formKey}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  String name = '';
  String password = '';
  String email = '';
  TextEditingController nameCon = TextEditingController();
  TextEditingController passwordCon = TextEditingController();
  TextEditingController emailCon = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
          key: widget.formKey,
          child: Column(
            children: [
              const SizedBox(height: 15),
              HideItem(
                visabl: !context.watch<AuthProvider>().isSignIn,
                maxHight: 78,
                child: _createTextFormField('E-mail adress', context),
              ),
              _createTextFormField('User name', context),
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
      decoration: InputDecoration(
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
                ? const Icon(Icons.check_circle_outline)
                : null,
        suffixIconColor: Theme.of(context).primaryColor,
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade500)),
        label: Text(label),
      ),
      validator: (value) {
        if (label == 'E-mail adress') {
          if (!context.read<AuthProvider>().isSignIn &&
              (value!.isEmpty ||
                  !value.contains('@') ||
                  !value.contains('.com'))) {
            return 'invalid email';
          }
        } else if (label == 'Password') {
          if (value!.isEmpty || value.length < 6) {
            return 'password must be six characters at least ';
          }
        } else {
          if (value!.isEmpty || value.length < 6) {
            return 'user must be six characters at least ';
          }
        }
        return null;
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
