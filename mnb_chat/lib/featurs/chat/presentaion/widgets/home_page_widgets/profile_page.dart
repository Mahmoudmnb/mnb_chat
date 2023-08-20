import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mnb_chat/core/app_theme.dart';
import 'package:mnb_chat/core/constant.dart';
import 'package:mnb_chat/featurs/auth/models/user_model.dart';
import 'package:mnb_chat/featurs/chat/presentaion/widgets/profile_widgets/list_tile_settting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../../../../Auth/presentation/pages/auth_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoding = false;
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
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onBackground,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15))),
            ),
          ],
        ),
        Positioned(
          top: deviceHeight * 0.02,
          left: deviceWidth * 0.1,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20)),
            width: deviceWidth * 0.8,
            height: deviceHeight * 0.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: deviceWidth * 0.3,
                  width: deviceWidth * 0.3,
                  decoration: BoxDecoration(
                      color: AppTheme.nameColors[
                              getNameLetters(Constant.currentUsre.name)] ??
                          Theme.of(context).colorScheme.background,
                      shape: BoxShape.circle),
                  child: isLoding
                      ? const CircularProgressIndicator()
                      : Text(
                          getNameLetters(Constant.currentUsre.name),
                          style: TextStyle(
                              fontSize: deviceWidth * 0.08,
                              fontWeight: FontWeight.bold),
                        ),
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
                  Constant.currentUsre.email,
                  overflow: TextOverflow.ellipsis,
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
                  horizontal: 5,
                ),
                height: deviceHeight * 0.35,
                width: deviceWidth,
                child: ListView(
                  children: [
                    ListTileSetting(
                        text: 'Change user image',
                        icon: Icons.update,
                        onTap: changeUserImage,
                        deviceWidth: deviceWidth),
                    const SizedBox(height: 10),
                    ListTileSetting(
                        text: 'Update user data',
                        icon: Icons.camera,
                        onTap: () =>
                            changeUserData(context, deviceWidth, deviceHeight),
                        deviceWidth: deviceWidth),
                    const SizedBox(height: 10),
                    ListTileSetting(
                        text: 'Log out',
                        icon: Icons.exit_to_app,
                        onTap: () => logOut(context),
                        deviceWidth: deviceWidth),
                  ],
                )))
      ]),
    );
  }

  void changeUserImage() async {
    ToastContext().init(context);

    ImagePicker imagePicker = ImagePicker();
    var p = await imagePicker.pickImage(source: ImageSource.gallery);
    if (p != null) {
      isLoding = true;
      setState(() {});
      File image = File(p.path);

      FirebaseStorage.instance
          .ref('profileImages')
          .child(Constant.currentUsre.email)
          .putFile(image)
          .snapshotEvents
          .listen((event) async {
        if (event.state == TaskState.success) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(Constant.currentUsre.email)
              .update({'ImgUrl': await event.ref.getDownloadURL()}).then(
                  (value) {
            isLoding = false;
            setState(() {});
            Toast.show('Image uploaded');
          });
        }
      });
    }
  }

  String getNameLetters(String name) {
    var splitedName = name.split(' ');
    var f = splitedName.length == 1
        ? splitedName.first.characters.first
        : splitedName.first.characters.first +
            splitedName.last.characters.first;
    return f.toUpperCase();
  }

  logOut(context) async {
    SharedPreferences db = await SharedPreferences.getInstance();
    db.remove('currentUser');
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => AuthPage(),
    ));
    await FirebaseAuth.instance.signOut();
  }

  changeUserData(BuildContext context, double deviceWidth, double deviceHight) {
    bool isLoding = false;
    TextEditingController nameCon =
        TextEditingController(text: Constant.currentUsre.name);
    TextEditingController emailCon =
        TextEditingController(text: Constant.currentUsre.email);
    TextEditingController passCon =
        TextEditingController(text: Constant.currentUsre.password);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          'Enter new data',
          style:
              TextStyle(color: Theme.of(context).textTheme.titleLarge!.color),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => SizedBox(
            height: deviceHight * 0.45,
            width: deviceWidth * 0.8,
            child: Column(
              children: [
                TextFormField(
                  controller: nameCon,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge!.color),
                  keyboardType: TextInputType.text,
                  cursorColor: Theme.of(context).textTheme.titleLarge!.color,
                  decoration: InputDecoration(
                    errorStyle: const TextStyle(color: Colors.red),
                    focusedErrorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    labelStyle: const TextStyle(color: Colors.black),
                    suffixIconColor: Colors.black,
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500)),
                    label: Text(
                      'Name',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge!.color),
                    ),
                  ),
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge!.color),
                  controller: emailCon,
                  keyboardType: TextInputType.text,
                  cursorColor: Theme.of(context).textTheme.titleLarge!.color,
                  decoration: InputDecoration(
                    errorStyle: const TextStyle(color: Colors.red),
                    focusedErrorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    labelStyle: const TextStyle(color: Colors.black),
                    suffixIconColor: Colors.black,
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500)),
                    label: Text(
                      'E-mail',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge!.color),
                    ),
                  ),
                  validator: (value) {
                    if (emailCon.text.isEmpty ||
                        !emailCon.text.contains('@') ||
                        !emailCon.text.contains('.com')) {
                      return 'invalid Email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passCon,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge!.color),
                  keyboardType: TextInputType.visiblePassword,
                  cursorColor: Theme.of(context).textTheme.titleLarge!.color,
                  decoration: InputDecoration(
                    errorStyle: const TextStyle(color: Colors.red),
                    focusedErrorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    labelStyle: const TextStyle(color: Colors.black),
                    suffixIconColor: Colors.black,
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500)),
                    label: Text(
                      'password',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge!.color),
                    ),
                  ),
                  validator: (value) {
                    if (passCon.text.isEmpty || passCon.text.length < 6) {
                      return 'Password should be more than six letters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      isLoding = true;
                      setState(() {});
                      ToastContext().init(context);
                      if (nameCon.text.isEmpty || nameCon.text.length < 6) {
                        Toast.show('name should be more than six letters',
                            duration: 2);
                      } else if (emailCon.text.isEmpty ||
                          !emailCon.text.contains('@') ||
                          !emailCon.text.contains('.com')) {
                        Toast.show('Invalid E-mail', duration: 2);
                      } else if (nameCon.text.isEmpty ||
                          nameCon.text.length < 6) {
                        Toast.show('password should be more than six letters',
                            duration: 2);
                      } else {
                        //! change data of current user
                        //! modify loading
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(Constant.currentUsre.email)
                            .update({
                          'email': emailCon.text,
                          'name': nameCon.text,
                          'password': passCon.text
                        }).onError((error, stackTrace) {
                          print(error);
                          isLoding = false;
                          setState(() {});
                        }).then((value) {
                          var token = Constant.currentUsre.token;
                          Constant.currentUsre = UserModel(
                              password: passCon.text,
                              name: nameCon.text,
                              email: emailCon.text,
                              token: token);
                          isLoding = false;
                          setState(() {});
                        });
                      }
                    },
                    child: isLoding
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.background,
                            ),
                          )
                        : const Text('Update'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
