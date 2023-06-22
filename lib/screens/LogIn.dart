// ignore_for_file: avoid_init_to_null, prefer_final_fields, await_only_futures, sized_box_for_whitespace, avoid_unnecessary_containers, file_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_jupe_skensa/components/Button.dart';
import 'package:e_jupe_skensa/config/variable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:toast/toast.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  double spaceField = 7;
  final _formKey = GlobalKey<FormState>();
  var _txtEmail = TextEditingController();
  var _txtPass = TextEditingController();
  bool _passwordVisible = false;
  var emailError = null;
  var passError = null;
  var loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _passwordVisible = false;
  }

  void login() async {
    emailError = null;
    passError = null;
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          loading = true;
          _formKey.currentState!.validate();
        });
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _txtEmail.text, password: _txtPass.text);

        // ignore: unused_local_variable
        final userRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .get()
            .then(
          (value) async {
            final data = await value.data();
            if (data?['fullName'] == null ||
                data?['role'] == null ||
                data?['email'] == null) {
              setState(() {
                emailError = 'akun tidak di temukan';
                _formKey.currentState!.validate();
                loading = false;
              });
            } else {
              final userBox = Hive.box('user');

              userBox.put('fullName', data?['fullName']);
              userBox.put('role', data?['role']);
              userBox.put('email', data?['email']);
              userBox.put('profile', data?['profile'] ?? defautlPic);
              userBox.put('uid', value.id);
              print(userBox.get('fullName'));
              print(userBox.get('role'));
              print(userBox.get('email'));
              print(userBox.get('profile'));
              print(userBox.get('uid'));
              // userBox.putAll(data as Map<dynamic, dynamic>);
              Toast.show(
                successMasukText,
                duration: 2,
                backgroundColor: Colors.white,
                gravity: Toast.bottom,
                rootNavigator: false,
                textStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.black,
                ),
              );

              setState(() {
                Timer.periodic(const Duration(seconds: 1), (timer) {
                  loading = false;
                  Navigator.pushReplacementNamed(context, homeRoute);
                });
              });
            }
          },
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          loading = false;
        });
        if (e.code == 'weak-password') {
          passError = 'password minimal 6 karakter';
        } else if (e.code == 'wrong-password') {
          passError = 'password salah';
        } else if (e.code == 'email-already-in-use') {
          emailError = 'email sudah digunakan';
        } else if (e.code == 'invalid-email') {
          emailError = 'email tidak valid';
        } else if (e.code == 'user-not-found') {
          emailError = 'email belum terdaftar';
        }
        setState(() {
          _formKey.currentState!.validate();
        });
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    var screen = MediaQuery.of(context).size;
    ToastContext().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            width: screen.width,
            height: screen.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientPrimary,
              ),
            ),
            alignment: Alignment.center,
            child: SafeArea(
              child: Container(
                height: screen.height,
                width: screen.width,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 40),
                          child: Lottie.asset(
                            loginAnimation,
                            width: screen.width * 0.9,
                          ),
                        ),
                        Lottie.asset(waveAnimation),
                      ],
                    ),
                    Container(
                      height: screen.height,
                      width: screen.width,
                      child: Center(
                        child: Container(
                          width: screen.width * 0.85,
                          decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                loginText,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: semibold,
                                ),
                              ),
                              SizedBox(
                                height: spaceField,
                              ),
                              Form(
                                key: _formKey,
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      TextFormField(
                                        controller: _txtEmail,
                                        cursorColor: fieldPrimary,
                                        decoration: InputDecoration(
                                          alignLabelWithHint: false,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 1.2,
                                              color: fieldPrimary,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 1.2,
                                              color: fieldPrimary,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 1.2,
                                              color: Colors.blue.shade500,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: Colors.blue.shade500,
                                              width: 1.2,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 1.2,
                                              color: Colors.pink.shade400,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 2,
                                            horizontal: 10,
                                          ),
                                          errorStyle: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w300,
                                            height: 0.5,
                                          ),
                                          fillColor: Colors.white70,
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
                                          } else if (emailError != null) {
                                            return emailError;
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: spaceField),
                                      TextFormField(
                                        obscureText: !_passwordVisible,
                                        controller: _txtPass,
                                        cursorColor: fieldPrimary,
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              // Based on passwordVisible state choose the icon
                                              _passwordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.black87,
                                            ),
                                            onPressed: () {
                                              // Update the state i.e. toogle the state of passwordVisible variable
                                              setState(() {
                                                _passwordVisible =
                                                    !_passwordVisible;
                                              });
                                            },
                                          ),
                                          alignLabelWithHint: false,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 1.2,
                                              color: fieldPrimary,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 1.2,
                                              color: fieldPrimary,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 1.2,
                                              color: Colors.blue.shade500,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 1.2,
                                              color: Colors.blue.shade500,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 1.2,
                                              color: Colors.pink.shade400,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 2,
                                            horizontal: 10,
                                          ),
                                          errorStyle: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w300,
                                            height: 0.5,
                                          ),
                                          fillColor: Colors.white70,
                                          filled: true,
                                          hintText: passwordText,
                                          hintStyle: GoogleFonts.poppins(
                                            color: fieldPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.isEmpty ||
                                              value.trim() == '') {
                                            return passwordEmpty;
                                          } else if (passError != null) {
                                            return passError;
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(
                                        height: spaceField * 3,
                                      ),
                                      Button(
                                        onPress: () => {login()},
                                        height: 45,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Text(
                                          loginText,
                                          style: GoogleFonts.poppins(
                                            color: textPrimary,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      accountNotExistText,
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    InkWell(
                                      onTap: () => {
                                        Navigator.pushNamed(
                                            context, signupRoute)
                                      },
                                      child: Text(
                                        signupText.toLowerCase(),
                                        style: GoogleFonts.poppins(
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
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
}
