// ignore_for_file: prefer_final_fields, prefer_const_constructors, prefer_typing_uninitialized_variables, await_only_futures, sized_box_for_whitespace, avoid_unnecessary_containers, avoid_print, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_jupe_skensa/components/Button.dart';
import 'package:e_jupe_skensa/config/variable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:toast/toast.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String? _txtRole;
  double spaceField = 7;
  late bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();
  var _txtEmail = TextEditingController();
  var _txtFullName = TextEditingController();
  var _txtPass = TextEditingController();

  var loading = false;
  var emailError;
  var passError;
  @override
  void initState() {
    _passwordVisible = false;
    super.initState();
  }

  void signup() async {
    emailError = null;
    passError = null;
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          loading = true;
          _formKey.currentState!.validate();
        });
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _txtEmail.text, password: _txtPass.text);

        final userRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid);
        // ignore: unused_local_variable
        final userFirebase = await userRef.set(
          {
            "fullName": _txtFullName.text,
            "email": _txtEmail.text,
            "role": _txtRole,
            "profile": null,
            "password": _txtPass.text,
          },
        ).then((value) {
          return userRef.get();
        }).then(
          (value) async {
            final data = value.data();
            final userBox = Hive.box('user');
            userBox.put('fullName', data?['fullName']);
            userBox.put('role', data?['role']);
            userBox.put('email', data?['email']);
            userBox.put('profile', data?['profile'] ?? defautlPic);
            userBox.put('uid', value.id);
            setState(() {
              loading = false;
            });
            Toast.show(
              successDaftarText,
              duration: 2,
              backgroundColor: Colors.white,
              gravity: Toast.bottom,
              rootNavigator: false,
              textStyle: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black,
              ),
            );
            Navigator.pushReplacementNamed(context, homeRoute);
          },
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          loading = false;
        });
        if (e.code == 'weak-password') {
          passError = 'password minimal 6 karakter';
        } else if (e.code == 'email-already-in-use') {
          emailError = 'email sudah digunakan';
        } else if (e.code == 'invalid-email') {
          emailError = 'email tidak valid';
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
    SchedulerBinding.instance.addPostFrameCallback((_) {
      var userBox = Hive.box('user');
      if (userBox.isNotEmpty) {
        Navigator.pushReplacementNamed(context, homeRoute);
      }
    });
    ToastContext().init(context);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
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
                          margin: EdgeInsets.only(top: 40),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                signupText,
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
                                        controller: _txtFullName,
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
                                              width: 1.2,
                                              color: Colors.blue.shade500,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 1.2,
                                              color: Colors.pink,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 2,
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
                                      SizedBox(height: spaceField),
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
                                              width: 1.2,
                                              color: Colors.blue.shade500,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 1.2,
                                              color: Colors.pink,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
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
                                              _passwordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.black87,
                                            ),
                                            onPressed: () {
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
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 1.2,
                                              color: Colors.pink,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 2,
                                            horizontal: 10,
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
                                      SizedBox(height: spaceField),
                                      DropdownButtonFormField(
                                        value: _txtRole,
                                        isExpanded: true,
                                        onChanged: (value) {
                                          setState(() {
                                            _txtRole = value.toString();
                                          });
                                        },
                                        onSaved: (value) {
                                          setState(() {
                                            _txtRole = value.toString();
                                          });
                                        },
                                        validator: (Object? value) {
                                          if (value == null) {
                                            return roleEmpty;
                                          } else {
                                            return null;
                                          }
                                        },
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
                                              width: 1.2,
                                              color: Colors.blue.shade500,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 1.2,
                                              color: Colors.pink,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 2,
                                            horizontal: 10,
                                          ),
                                          errorStyle: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w300,
                                            height: 0.5,
                                          ),
                                          fillColor: Colors.white70,
                                          filled: true,
                                          hintText: signupAsText,
                                          hintStyle: GoogleFonts.poppins(
                                            color: fieldPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        items: role.map((val) {
                                          return DropdownMenuItem(
                                            value: val.toString().toLowerCase(),
                                            child: Text(
                                              val,
                                              style: GoogleFonts.poppins(
                                                color: fieldPrimary,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(
                                        height: spaceField * 3,
                                      ),
                                      // Spacer(),
                                      Button(
                                        onPress: () => {signup()},
                                        height: 45,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Text(
                                          signupText,
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
                              SizedBox(height: 10),
                              Container(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      accountExistText,
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    InkWell(
                                      onTap: () => {
                                        Navigator.pushNamed(context, loginRoute)
                                      },
                                      child: Text(
                                        loginText.toLowerCase(),
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
              child: SpinKitCircle(color: Colors.white),
            )
        ],
      ),
    );
  }
}
