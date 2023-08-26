import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../../../../../core/app_theme.dart';
import '../../../../../core/constant.dart';

import '../../../../Auth/presentation/pages/auth_page.dart';
import '../../../../auth/models/user_model.dart';
import '../profile_widgets/list_tile_settting.dart';

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
                Constant.currentUsre.imgUrl == null ||
                        Constant.currentUsre.imgUrl == ''
                    ? Container(
                        alignment: Alignment.center,
                        height: deviceWidth * 0.3,
                        width: deviceWidth * 0.3,
                        decoration: BoxDecoration(
                            color: AppTheme.nameColors[getNameLetters(
                                    Constant.currentUsre.name)] ??
                                Theme.of(context).colorScheme.background,
                            shape: BoxShape.circle),
                        child: isLoding
                            ? const CircularProgressIndicator()
                            : Text(
                                getNameLetters(Constant.currentUsre.name),
                                style: TextStyle(
                                    fontSize: deviceWidth * 0.08,
                                    fontWeight: FontWeight.bold),
                              ))
                    : SizedBox(
                        height: deviceWidth * 0.3,
                        width: deviceWidth * 0.3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(500),
                          child: CachedNetworkImage(
                              errorWidget: (context, url, error) => Text(
                                    getNameLetters(Constant.currentUsre.name),
                                    style: TextStyle(
                                        fontSize: deviceWidth * 0.08,
                                        fontWeight: FontWeight.bold),
                                  ),
                              progressIndicatorBuilder:
                                  (context, url, progress) =>
                                      CircularProgressIndicator(),
                              imageUrl: Constant.currentUsre.imgUrl!),
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
    bool isLoading = false;
    if (!isLoding) {
      isLoding = true;
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
          String imgUrl = await event.ref.getDownloadURL();
          if (event.state == TaskState.success) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(Constant.currentUsre.email)
                .update({'ImgUrl': imgUrl}).then((value) async {
              var s =
                  FirebaseFirestore.instance.collection('users').snapshots();
              s.listen((event1) {
                event1.docs.forEach((element) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(element.id)
                      .collection('friends')
                      .snapshots()
                      .listen((event2) {
                    event2.docs.forEach((element2) async {
                      if (element2.id == Constant.currentUsre.email) {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(element.id)
                            .collection('friends')
                            .doc(element2.id)
                            .update({'toImage': imgUrl});
                      }
                    });
                  });
                });
              });
              Constant.currentUsre.imgUrl = await event.ref.getDownloadURL();
              SharedPreferences db = await SharedPreferences.getInstance();
              db.setString(
                  'currentUser', jsonEncode(Constant.currentUsre.toJson()));
              isLoding = false;
              setState(() {});
              Toast.show('Image uploaded');
              isLoding = false;
            });
          }
        });
      }
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          'Log out',
          style:
              TextStyle(color: Theme.of(context).textTheme.titleLarge!.color),
        ),
        content: Text(
          'Are you realy want to log out?',
          style:
              TextStyle(color: Theme.of(context).textTheme.titleLarge!.color),
        ),
        actions: [
          TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Yes',
                style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge!.color),
              )),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'No',
                style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge!.color),
              ))
        ],
      ),
    ).then((value) async {
      if (value != null && value == true) {
        SharedPreferences db = await SharedPreferences.getInstance();
        db.remove('currentUser');
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => AuthPage(),
        ));
      }
    });
  }

  changeUserData(BuildContext context, double deviceWidth, double deviceHight) {
    bool isLoding = false;
    TextEditingController nameCon =
        TextEditingController(text: Constant.currentUsre.name);
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
            height: deviceHight * 0.3,
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
                      } else if (nameCon.text.isEmpty ||
                          nameCon.text.length < 6) {
                        Toast.show('password should be more than six letters',
                            duration: 2);
                      } else {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(Constant.currentUsre.email)
                            .update({
                          'name': nameCon.text.trim(),
                          'password': passCon.text.trim()
                        }).then((value) async {
                          UserModel userModel = Constant.currentUsre;
                          Constant.currentUsre = UserModel(
                              password: passCon.text.trim(),
                              name: nameCon.text.trim(),
                              email: userModel.email,
                              token: userModel.token);
                          SharedPreferences db =
                              await SharedPreferences.getInstance();
                          db.setString('currentUser',
                              jsonEncode(Constant.currentUsre.toJson()));
                          isLoding = false;
                          setState(() {});
                          Navigator.of(context).pop();
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
    ).then((value) {
      setState(() {});
    });
  }
}
