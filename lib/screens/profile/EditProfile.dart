// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_final_fields, avoid_print, file_names

import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_jupe_skensa/components/Button.dart';
import 'package:e_jupe_skensa/config/variable.dart';
import 'package:e_jupe_skensa/models/UserModel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  UserModel? user;
  double spaceField = 7;
  final _formKey = GlobalKey<FormState>();
  var _txtNama = TextEditingController();
  var _txtEmail = TextEditingController();
  var _txtRole = TextEditingController();
  var loading = false;

  void saveEdit(context) async {
    loading = true;
    var db = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    await db.update({'fullName': _txtNama.text}).then(
      (value) async {
        var tmpUser = await db.get();
        var userBox = Hive.box('user');
        userBox.putAll({
          'email': tmpUser.data()?['email'],
          'fullName': tmpUser.data()?['fullName'],
          'role': tmpUser.data()?['role'],
          'uid': tmpUser.id,
          'profile': tmpUser.data()?['profile']
        });
        setState(() {
          user = UserModel(
            email: tmpUser.data()?['email'],
            fullName: tmpUser.data()?['fullName'],
            role: tmpUser.data()?['role'],
            uid: tmpUser.id,
            profile: tmpUser.data()?['profile'],
          );
        });
        loading = false;
        Navigator.pushReplacementNamed(context, homeRoute);
      },
    );
  }

  void removePicture() async {
    loading = true;
    var db = FirebaseFirestore.instance;
    await db
        .collection('users')
        .doc(user!.uid)
        .update({'profile': defautlPic}).then((value) {
      loading = false;
    });
  }

  Future<void> pickMedia(context, source) async {
    Navigator.of(context).pop();

    File? _photo;
    ImagePicker imagePicker = ImagePicker();
    XFile? image = await imagePicker.pickImage(
      source: source,
      imageQuality: 50,
      preferredCameraDevice: CameraDevice.front,
    );

    setState(() {
      if (image != null) {
        _photo = File(image.path);
        uploadFile(_photo);
      } else {
        print('No image selected.');
      }
    });
    print(image!.path);
  }

  Future uploadFile(_photo) async {
    loading = true;
    if (_photo == null) return;
    final fileName = basename(_photo!.path);
    final destination =
        'files/${DateTime.now().millisecondsSinceEpoch}-$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      var image = await ref.putFile(_photo!);
      await image.ref.getDownloadURL().then((value) async {
        final db = FirebaseFirestore.instance;
        await db.collection('users').doc(user!.uid).update({'profile': value});
        loading = false;

        var userBox = Hive.box('user');
        userBox.putAll({
          'email': user!.email,
          'fullName': user!.fullName,
          'role': user!.role,
          'uid': user!.uid,
          'profile': value
        });
        setState(() {
          user = UserModel(
            email: user!.email,
            fullName: user!.fullName,
            role: user!.role,
            uid: user!.uid,
            profile: value,
          );
        });
      });
    } catch (e) {
      loading = false;
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      var userBox = Hive.box('user');
      user = UserModel(
        email: userBox.get('email'),
        fullName: userBox.get('fullName'),
        role: userBox.get('role'),
        uid: userBox.get('uid'),
        profile: userBox.get('profile'),
      );
      _txtNama.value = TextEditingValue(text: user!.fullName);
      _txtEmail.value = TextEditingValue(text: user!.email);
      _txtRole.value = TextEditingValue(text: user!.role);
    }

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    var screen = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            width: screen.width,
            height: screen.height,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                Container(
                  height: screen.height * 0.32,
                  width: screen.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                      image: NetworkImage('${user!.profile}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).viewPadding.top),
                  alignment: Alignment.center,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                    child: Container(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: screen.height * 0.2 +
                            MediaQuery.of(context).viewPadding.top,
                      ),
                      child: Container(
                        height: screen.width * 0.4,
                        width: screen.width * 0.4,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage('${user!.profile}'),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                              spreadRadius: -1,
                              color: Colors.black.withOpacity(0.2),
                            )
                          ],
                          borderRadius: BorderRadius.circular(999999),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Material(
                          borderRadius: BorderRadius.circular(999999),
                          clipBehavior: Clip.antiAlias,
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return openImage(context);
                                },
                              )
                            },
                            splashColor: Colors.black.withOpacity(0.3),
                            child: Container(
                              height: screen.width * 0.4,
                              width: screen.width * 0.4,
                              alignment: Alignment.center,
                              color: Colors.black.withOpacity(0.1),
                              child: FaIcon(
                                FontAwesomeIcons.camera,
                                size: 40,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        // height: screen.height,
                        margin: const EdgeInsets.only(
                          top: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.blue.shade300.withOpacity(0.5),
                            Colors.blue.shade400.withOpacity(0.5)
                          ]),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(50),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: _txtNama,
                                    cursorColor: fieldPrimary,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      height: 1,
                                      color: Colors.grey.shade700,
                                    ),
                                    decoration: InputDecoration(
                                      enabled: true,
                                      alignLabelWithHint: false,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          style: BorderStyle.none,
                                          width: 1.2,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          style: BorderStyle.none,
                                          width: 1.2,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          style: BorderStyle.solid,
                                          width: 1.2,
                                          color: Colors.blue.shade400,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: 10,
                                      ),
                                      errorStyle: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300,
                                        height: 0.5,
                                      ),
                                      fillColor: Colors.white70,
                                      filled: true,
                                      hintText: fullNameText,
                                      hintStyle: GoogleFonts.poppins(
                                        color: fieldPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value.trim() == '') {
                                        return fullNameEmpty;
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: spaceField,
                                  ),
                                  TextFormField(
                                    enabled: false,
                                    controller: _txtEmail,
                                    cursorColor: fieldPrimary,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      height: 1,
                                      color: Colors.grey.shade700,
                                    ),
                                    decoration: InputDecoration(
                                      enabled: true,
                                      alignLabelWithHint: false,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          style: BorderStyle.none,
                                          width: 1.2,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          style: BorderStyle.none,
                                          width: 1.2,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          style: BorderStyle.solid,
                                          width: 1.2,
                                          color: Colors.blue.shade400,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: 10,
                                      ),
                                      errorStyle: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300,
                                        height: 0.5,
                                      ),
                                      fillColor:
                                          Colors.grey.shade300.withOpacity(0.7),
                                      filled: true,
                                      hintText: emailText,
                                      hintStyle: GoogleFonts.poppins(
                                        color: fieldPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value.trim() == '') {
                                        return emailEmpty;
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: spaceField,
                                  ),
                                  TextFormField(
                                    enabled: false,
                                    controller: _txtRole,
                                    cursorColor: fieldPrimary,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      height: 1,
                                      color: Colors.grey.shade700,
                                    ),
                                    decoration: InputDecoration(
                                      enabled: true,
                                      alignLabelWithHint: false,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          style: BorderStyle.none,
                                          width: 1.2,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          style: BorderStyle.none,
                                          width: 1.2,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          style: BorderStyle.solid,
                                          width: 1.2,
                                          color: Colors.blue.shade400,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: 10,
                                      ),
                                      errorStyle: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300,
                                        height: 0.5,
                                      ),
                                      fillColor:
                                          Colors.grey.shade300.withOpacity(0.7),
                                      filled: true,
                                      hintText: roleText,
                                      hintStyle: GoogleFonts.poppins(
                                        color: fieldPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value.trim() == '') {
                                        return roleEmpty;
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: spaceField * 1.3),
                            Button(
                              onPress: () {
                                saveEdit(context);
                              },
                              height: 50,
                              colors: gradientPrimary,
                              borderRadius: BorderRadius.circular(10),
                              child: Text(
                                simpanText,
                                style: GoogleFonts.poppins(
                                    fontSize: 14, color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).viewPadding.top + 70,
                  width: screen.width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).viewPadding.top,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          width: screen.width,
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9999),
                              color: Colors.grey.shade300.withOpacity(0.5),
                            ),
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            // alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  editProfileText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.grey.shade300.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(99999),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            splashColor: Colors.white54,
                            onTap: () => {Navigator.pop(context)},
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              child: FaIcon(
                                FontAwesomeIcons.arrowLeft,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (loading)
            Container(
              height: screen.height,
              width: screen.width,
              color: Colors.black.withOpacity(0.35),
              child: const SpinKitCircle(color: Colors.white),
            )
        ],
      ),
    );
  }

  Widget openImage(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      width: MediaQuery.of(context).size.width,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(40),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 40,
            ),
            ListTile(
              onTap: (() {
                pickMedia(context, ImageSource.gallery);
              }),
              title: Text(
                fromGalleryText,
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              minLeadingWidth: 5,
              leading: const Icon(
                Icons.image_outlined,
                color: Colors.grey,
              ),
            ),
            const Divider(
              height: 5,
              color: Colors.grey,
            ),
            ListTile(
              onTap: () {
                pickMedia(context, ImageSource.camera);
              },
              title: Text(
                fromCameraText,
                style: GoogleFonts.poppins(
                  // color: darkTheme ? Colors.grey : purple,
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              minLeadingWidth: 5,
              leading: const Icon(
                Icons.camera_alt,
                // color: darkTheme ? Colors.grey : purple,
                color: Colors.grey,
              ),
            ),
            const Divider(
              height: 5,
              color: Colors.grey,
            ),
            ListTile(
              onTap: () {
                removePicture();
              },
              title: Text(
                removeProfileText,
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              minLeadingWidth: 5,
              leading: const Icon(
                Icons.delete,
                color: Colors.grey,
              ),
            ),
            const Divider(
              height: 5,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
