// ignore_for_file: prefer_final_fields, prefer_typing_uninitialized_variables, file_names

import 'package:e_jupe_skensa/config/variable.dart';
import 'package:e_jupe_skensa/models/JurnalModel.dart';
import 'package:e_jupe_skensa/models/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DetailJurnal extends StatefulWidget {
  const DetailJurnal({super.key});

  @override
  State<DetailJurnal> createState() => _DetailJurnalState();
}

class _DetailJurnalState extends State<DetailJurnal> {
  double spaceField = 7;
  final _formKey = GlobalKey<FormState>();
  var _txtJudul = TextEditingController();
  var _txtDeskripsi = TextEditingController();
  var _txtFullName = '';
  var jurnal;
  UserModel? user;
  @override
  void initState() {
    var userBox = Hive.box('user');
    user = UserModel(
      uid: userBox.get('uid'),
      fullName: userBox.get('fullName'),
      email: userBox.get('email'),
      role: userBox.get('role'),
    );
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (TickerMode.of(context)) {
      setState(() {
        jurnal = ModalRoute.of(context)!.settings.arguments as JurnalModel;
        _txtJudul.value = TextEditingValue(text: jurnal.judul);
        _txtDeskripsi.value = TextEditingValue(text: jurnal.deskripsi);
        if (user!.role != 'siswa') {
          _txtFullName = jurnal.user!.fullName;
        }
      });
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
      body: Container(
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
                              detailJurnalText,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            detailJurnalText,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: semibold,
                            ),
                          ),
                          if (user!.role != 'siswa')
                            Text(
                              _txtFullName,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          SizedBox(
                            height: spaceField,
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  judulText,
                                  style: GoogleFonts.poppins(fontSize: 15),
                                  textAlign: TextAlign.left,
                                ),
                                TextFormField(
                                  controller: _txtJudul,
                                  cursorColor: fieldPrimary,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    height: 1,
                                    color: Colors.grey.shade700,
                                  ),
                                  decoration: InputDecoration(
                                    enabled: false,
                                    alignLabelWithHint: false,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1.2,
                                        color: fieldPrimary,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1.2,
                                        color: fieldPrimary,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1.2,
                                        color: Colors.blue.shade500,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.blue.shade500,
                                        width: 1.2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1.2,
                                        color: Colors.pink.shade400,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
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
                                Text(
                                  deskripsiText,
                                  style: GoogleFonts.poppins(fontSize: 15),
                                  textAlign: TextAlign.left,
                                ),
                                TextFormField(
                                  maxLines: null,
                                  // expands: true,
                                  keyboardType: TextInputType.multiline,
                                  controller: _txtDeskripsi,
                                  cursorColor: fieldPrimary,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    height: 1,
                                    color: Colors.grey.shade700,
                                  ),
                                  decoration: InputDecoration(
                                    enabled: false,
                                    alignLabelWithHint: false,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1.2,
                                        color: fieldPrimary,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1.2,
                                        color: fieldPrimary,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1.2,
                                        color: Colors.blue.shade500,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1.2,
                                        color: Colors.blue.shade500,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1.2,
                                        color: Colors.pink.shade400,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 4,
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
    );
  }
}
