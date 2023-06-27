import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../widgets/widgets_paths.dart';

// ignore: must_be_immutable
class AuthPage extends StatelessWidget {
  AuthPage({Key? key}) : super(key: key);
  final formKey = GlobalKey<FormState>();
  final resetpasswordKay = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    ToastContext toastContext = ToastContext();
    toastContext.init(context);
    final deviceSize = MediaQuery.of(context).size;
    double heightOfDevice = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top +
            MediaQuery.of(context).padding.bottom);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onBackground,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: heightOfDevice * 0.16,
                    child: Center(
                      child: Text(
                        'MNB CHAT',
                        style: TextStyle(
                            fontSize: deviceSize.width * 0.1,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    height: heightOfDevice * 0.84,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HideItem(
                              maxHight: context.watch<AuthProvider>().isSignIn
                                  ? heightOfDevice * 0.08
                                  : heightOfDevice * 0.02,
                              visabl: true,
                              child: const SizedBox.shrink()),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: SwitchBetweenTwoText(
                              firstText: 'Create an account',
                              secondText: 'Welcome Back',
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25),
                            ),
                          ),
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: SwitchBetweenTwoText(
                                firstText: 'SignUp to continue',
                                secondText: 'LogIn to continue',
                                textStyle:
                                    TextStyle(color: Colors.grey.shade600),
                              )),
                          SizedBox(height: heightOfDevice * 0.02),
                          AuthForm(formKey: formKey),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.only(right: 20, top: 10),
                                  child: HideItem(
                                    visabl:
                                        context.watch<AuthProvider>().isSignIn,
                                    maxHight: 35,
                                    child: TextButton(
                                      onPressed: () {
                                        showResetDialog(context);
                                        // context
                                        //     .read<AuthProvider>()
                                        //     .changePassword();
                                      },
                                      child: const Text('Forgot password ?',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ))
                            ],
                          ),
                          SizedBox(height: heightOfDevice * 0.05),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  InkWell(
                                    onTap: context
                                            .read<AuthProvider>()
                                            .isButtonLoading
                                        ? null
                                        : () => logicButton(context),
                                    child: Container(
                                        alignment: Alignment.center,
                                        width: deviceSize.width * 0.8,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: !context
                                                .read<AuthProvider>()
                                                .isButtonLoading
                                            ? const SwitchBetweenTwoText(
                                                firstText: 'SIGN UP',
                                                secondText: 'LOG IN',
                                                textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1),
                                              )
                                            : const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )),
                                  ),
                                  const SizedBox(height: 15),
                                  // HideItem(
                                  //   visabl:
                                  //       context.watch<AuthProvider>().isSignIn,
                                  //   maxHight: 15,
                                  //   child: Text(
                                  //     'or connect with',
                                  //     overflow: TextOverflow.ellipsis,
                                  //     style: TextStyle(
                                  //         color: Colors.grey.shade600),
                                  //   ),
                                  // ),
                                  // HideItem(
                                  //     visabl: context
                                  //         .watch<AuthProvider>()
                                  //         .isSignIn,
                                  //     maxHight: 100,
                                  //     child: const AlternativeSignInMethod()),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const SwitchBetweenTwoText(
                                        firstText: 'Already have an account ?',
                                        secondText:
                                            '      dont have an account ?',
                                        textStyle: TextStyle(fontSize: 15),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context
                                              .read<AuthProvider>()
                                              .changeSignInOrSignUp();
                                        },
                                        child: const SwitchBetweenTwoText(
                                          firstText: 'sign in',
                                          secondText: 'sign up',
                                          textStyle: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  bool isLoding = false;
  Future<dynamic> showResetDialog(BuildContext context) {
    controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Reset password',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        content: Form(
            key: resetpasswordKay,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                errorStyle: const TextStyle(color: Colors.red),
                focusedErrorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                labelStyle: const TextStyle(color: Colors.black),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade500)),
                label: const Text(
                  'Email',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              validator: (value) {
                if ((value!.isEmpty ||
                    !value.contains('@') ||
                    !value.contains('.com'))) {
                  return 'invalid email';
                }
                return null;
              },
            )),
        alignment: Alignment.center,
        actions: [
          Center(
              child: StatefulBuilder(
            builder: (context, setState) => TextButton(
                onPressed: () async {
                  if (resetpasswordKay.currentState!.validate()) {
                    context
                        .read<AuthProvider>()
                        .changePassword(controller.text, context);
                  }
                },
                child: !isLoding
                    ? const Text(
                        'Reset',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 20),
                      )
                    : const CircularProgressIndicator()),
          ))
        ],
      ),
    );
  }

  logicButton(BuildContext context) async {
    bool isvalidete = formKey.currentState!.validate();
    if (isvalidete) {
      context.read<AuthProvider>().setButtonLoding(true);
      context.read<AuthProvider>().changeValidate(isvalidete);
      formKey.currentState!.save();
      if (context.read<AuthProvider>().isSignIn) {
        await context.read<AuthProvider>().signIn(context);
      } else {
        await context.read<AuthProvider>().signUp(context);
      }
      context.read<AuthProvider>().setButtonLoding(false);
    }
  }
}
