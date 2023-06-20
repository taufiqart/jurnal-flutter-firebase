// ignore_for_file: prefer_final_fields, await_only_futures, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_jupe_skensa/components/Button.dart';
import 'package:e_jupe_skensa/config/variable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';

class IsiJurnal extends StatefulWidget {
  const IsiJurnal({super.key});

  @override
  State<IsiJurnal> createState() => _IsiJurnalState();
}

class _IsiJurnalState extends State<IsiJurnal> {
  double spaceField = 7;
  final _formKey = GlobalKey<FormState>();
  var _txtJudul = TextEditingController();
  var _txtDeskripsi = TextEditingController();
  var loading = false;
  void submitJurnal() async {
    setState(() {
      loading = true;
    });
    var userBox = Hive.box('user');
    if (_formKey.currentState!.validate()) {
      var jurnalRef = await FirebaseFirestore.instance;
      await jurnalRef.collection('jurnal').add({
        "judul": _txtJudul.text,
        "deskripsi": _txtDeskripsi.text,
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "updatedAt": DateTime.now().millisecondsSinceEpoch,
        "userUid": userBox.get('uid')
      }).then((value) {
        setState(() {
          loading = false;
          Navigator.pop(context);
        });
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientPrimary,
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
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
                                  isiJurnalText,
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
                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 40),
                            child: Lottie.asset(
                              documentAnimation,
                              width: screen.width * 0.9,
                            ),
                          ),
                          Lottie.asset(waveAnimation),
                        ],
                      ),
                      Center(
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
                                isiJurnalText,
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
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      controller: _txtJudul,
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
                                        focusedErrorBorder: OutlineInputBorder(
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
                                        hintText: judulText,
                                        hintStyle: GoogleFonts.poppins(
                                          color: fieldPrimary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            value.trim() == '') {
                                          return judulEmpty;
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: spaceField),
                                    TextFormField(
                                      maxLines: null,
                                      // expands: true,
                                      keyboardType: TextInputType.multiline,
                                      controller: _txtDeskripsi,
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
                                        focusedErrorBorder: OutlineInputBorder(
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
                                        hintText: deskripsiText,
                                        hintStyle: GoogleFonts.poppins(
                                          color: fieldPrimary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            value.trim() == '') {
                                          return deskripsiEmpty;
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: spaceField * 4,
                                    ),
                                    Button(
                                      onPress: () {
                                        submitJurnal();
                                      },
                                      height: 45,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Text(
                                        submitText,
                                        style: GoogleFonts.poppins(
                                          color: textPrimary,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
}
