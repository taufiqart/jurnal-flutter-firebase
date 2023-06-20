// ignore_for_file: file_names, unnecessary_import

import 'dart:ui';

import 'package:e_jupe_skensa/components/Button.dart';
import 'package:e_jupe_skensa/config/variable.dart';
import 'package:e_jupe_skensa/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  double gapProfile = 8;
  UserModel? user;
  void logout() async {
    var db = FirebaseAuth.instance;
    await db.signOut().then((value) {
      Hive.box('user').clear();
      Navigator.pushReplacementNamed(context, onboardingRoute);
    });
  }

  @override
  void initState() {
    final userBox = Hive.box('user');
    user = UserModel(
      uid: userBox.get('uid'),
      fullName: userBox.get('fullName'),
      email: userBox.get('email'),
      role: userBox.get('role'),
      profile: userBox.get('profile'),
    );
    // TODO: implement initState
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    if (TickerMode.of(context)) {
      setState(() {
        user;
      });
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: screen.width,
        height: screen.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientTertiary),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              // left: 50,
              width: screen.width * 1.2,
              left: screen.height * 0.01 + 40,
              child: Transform.rotate(
                angle: 45.2,
                child: Container(
                  height: screen.height * 0.54,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff6366F1).withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    // color: Colors.blue,
                    gradient: const LinearGradient(
                      colors: [Color(0xffC4B5FD), Color(0xff6366F1)],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(99999),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: screen.height * 0.01,
              right: screen.height * 0.01 - 30,
              width: screen.width * 1.4,
              child: Transform.rotate(
                angle: 170.1,
                child: Container(
                  height: screen.height * 0.55,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade100, Colors.blue.shade500],
                      ),
                      // color: Colors.green,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(99999),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade300.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ]),
                ),
              ),
            ),
            Positioned(
              width: screen.width * 1.2,
              child: Container(
                height: screen.height * 0.5,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(999),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).viewPadding.top,
                  horizontal: screen.width * 0.3,
                ),
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: screen.width * 0.45,
                      height: screen.width * 0.45,
                      clipBehavior: Clip.antiAlias,
                      constraints: const BoxConstraints(
                        maxHeight: 150,
                        maxWidth: 150,
                      ),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage('${user!.profile}'),
                          fit: BoxFit.cover,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(99999),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: gapProfile * 2,
                    ),
                    Text(
                      user!.fullName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: semibold,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: gapProfile * 0.7,
                    ),
                    Text(
                      user!.email,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: gapProfile * 0.4,
                    ),
                    Text(
                      user!.role,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, editProfileRoute);
                      },
                      child: const FaIcon(
                        FontAwesomeIcons.pencil,
                        size: 15,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: screen.width,
                height: screen.height * 0.4,
                color: Colors.transparent,
                padding: const EdgeInsets.only(
                  bottom: 100,
                  left: 30,
                  right: 30,
                ),
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Button(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                        )
                      ],
                      height: 40,
                      onPress: () => {logout()},
                      borderRadius: BorderRadius.circular(10),
                      colors: [Colors.grey.shade100, Colors.white],
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const FaIcon(
                                FontAwesomeIcons.arrowRightFromBracket),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              signoutText,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
