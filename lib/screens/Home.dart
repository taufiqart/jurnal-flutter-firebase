// ignore_for_file: prefer_is_empty, unnecessary_string_interpolations, sized_box_for_whitespace, await_only_futures, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_jupe_skensa/components/Button.dart';
import 'package:e_jupe_skensa/components/ButtonCard.dart';
import 'package:e_jupe_skensa/config/variable.dart';
import 'package:e_jupe_skensa/models/AbsensiModel.dart';
import 'package:e_jupe_skensa/models/JurnalModel.dart';
import 'package:e_jupe_skensa/models/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  UserModel? user;
  final userBox = Hive.box('user');
  @override
  void initState() {
    super.initState();
    if (userBox.get('uid') == null) {
      Navigator.pushReplacementNamed(context, onboardingRoute);
    }
    // ignore: unnecessary_null_comparison
    if (user == null || user!.uid == null) {
      user = UserModel(
        uid: userBox.get('uid'),
        fullName: userBox.get('fullName'),
        email: userBox.get('email'),
        role: userBox.get('role'),
        profile: userBox.get('profile'),
      );
      setState(() {
        user;
      });
    }
    // TODO: implement initState
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  String greeting() {
    var h = DateTime.now().hour;

    if (h >= 3 && h <= 9) {
      return greetingText[0];
      // Selamat pagi.
    } else if (h >= 9 && h <= 15) {
      return greetingText[1];
      // Selamat siang.
    } else if (h >= 15 && h <= 18) {
      return greetingText[2];
      // Selamat sore.
    } else {
      return greetingText[3];
      // Selamat malam.
    }
  }

  Future getUsers() async {
    var db = FirebaseFirestore.instance;
    var userRef = await db.collection('users').get();
    var users = await userRef.docs.map((data) {
      return UserModel(
        uid: data.id,
        fullName: data.data()['fullName'],
        email: data.data()['email'],
        role: data.data()['role'],
      );
    });

    return users;
  }

  Future<Iterable<AbsensiModel>> getAbsensi() async {
    Future<Iterable<AbsensiModel>> siswa() async {
      var db = FirebaseFirestore.instance;
      var absensiRef = await db
          .collection('absensi')
          .orderBy('createdAt', descending: true)
          .get();
      var absensis = await absensiRef.docs.map((data) {
        return AbsensiModel(
          uid: data.id,
          absensi: data.data()['absensi'],
          status: data.data()['status'],
          createdAt: data.data()['createdAt'],
          updatedAt: data.data()['updatedAt'],
          userUid: data.data()['userUid'],
        );
      });
      if (userBox.get('role') == 'siswa') {
        absensis =
            absensis.where((element) => element.userUid == userBox.get('uid'));
      }
      return absensis;
    }

    Future<Iterable<AbsensiModel>> other() async {
      var db = FirebaseFirestore.instance;
      var absensiRef = await db
          .collection('absensi')
          .orderBy('createdAt', descending: true)
          .get();
      var users = await getUsers();
      var absensis = await absensiRef.docs.map((data) {
        UserModel? user;
        for (var tmpUser in users) {
          if (data.data()['userUid'] == tmpUser.uid) {
            user = tmpUser as UserModel;
            break;
          }
        }
        return AbsensiModel(
          uid: data.id,
          absensi: data.data()['absensi'],
          status: data.data()['status'],
          createdAt: data.data()['createdAt'],
          updatedAt: data.data()['updatedAt'],
          userUid: data.data()['userUid'],
          user: user,
        );
      });
      return absensis;
    }

    if (user!.role == 'siswa') {
      return await siswa();
    } else {
      return await other();
    }
  }

  Future<Iterable<JurnalModel>> getJurnal() async {
    var db = FirebaseFirestore.instance;
    Future<Iterable<JurnalModel>> siswa() async {
      var jurnalRef = await db
          .collection('jurnal')
          .where('userUid', isEqualTo: user!.uid)
          .get();
      var jurnals = await jurnalRef.docs.map((data) {
        return JurnalModel(
          uid: data.id,
          judul: data.data()['judul'],
          deskripsi: data.data()['deskripsi'],
          createdAt: data.data()['createdAt'],
          updatedAt: data.data()['updatedAt'],
          userUid: data.data()['userUid'],
        );
      });
      return jurnals;
    }

    Future<Iterable<JurnalModel>> other() async {
      var jurnalRef = await db
          .collection('jurnal')
          .orderBy('createdAt', descending: true)
          .get();
      var users = await getUsers();
      var jurnals = await jurnalRef.docs.map((data) {
        UserModel? user;
        for (var tmpUser in users) {
          if (data.data()['userUid'] == tmpUser.uid) {
            user = tmpUser;
            break;
          }
        }

        return JurnalModel(
          uid: data.id,
          judul: data.data()['judul'],
          deskripsi: data.data()['deskripsi'],
          createdAt: data.data()['createdAt'],
          updatedAt: data.data()['updatedAt'],
          userUid: data.data()['userUid'],
          user: user,
        );
      });

      return jurnals;
    }

    if (user!.role == 'siswa') {
      return await siswa();
    } else {
      return await other();
    }
  }

  void detailJurnal(jurnal) {
    Navigator.pushNamed(
      context,
      detailJurnalRoute,
      arguments: jurnal as JurnalModel,
    );
  }

  void fullJurnal() {
    Navigator.pushNamed(context, jurnalRoute, arguments: user as UserModel);
  }

  void fullAbsensi() {
    Navigator.pushNamed(context, absensiRoute, arguments: user as UserModel);
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    if (userBox.get('uid') == null &&
        userBox.get('email') == null &&
        userBox.get('role') == null &&
        userBox.get('profile') == null &&
        userBox.get('fullName') == null) {
      Navigator.pushReplacementNamed(context, onboardingRoute);
    }

    // ignore: unnecessary_null_comparison
    if (user == null || user!.uid == null) {
      user = UserModel(
        uid: userBox.get('uid'),
        fullName: userBox.get('fullName'),
        email: userBox.get('email'),
        role: userBox.get('role'),
        profile: userBox.get('profile'),
      );
      setState(() {
        user;
      });
    }
    if (TickerMode.of(context)) {
      // ignore: unnecessary_null_comparison
      if (user == null || user!.uid == null) {
        user = UserModel(
          uid: userBox.get('uid'),
          fullName: userBox.get('fullName'),
          email: userBox.get('email'),
          role: userBox.get('role'),
          profile: userBox.get('profile'),
        );
        setState(() {
          user;
        });
      }
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: screen.width,
        height: screen.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientPrimary,
            transform: const GradientRotation(40),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: screen.height * 0.22,
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: screen.width * 0.7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting(),
                                style: GoogleFonts.poppins(
                                  color: textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                userBox.get('fullName'),
                                style: GoogleFonts.poppins(
                                  fontWeight: semibold,
                                  color: textPrimary,
                                  fontSize: 17,
                                  height: 1.2,
                                ),
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.white,
                            image: DecorationImage(
                              image: NetworkImage('${user!.profile}'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      ],
                    ),
                    const Spacer(),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientPrimary),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Image.asset(
                            logo,
                            height: 40,
                          ),
                          const SizedBox(
                            width: 17,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nameApp,
                                style: GoogleFonts.poppins(
                                    fontWeight: semibold,
                                    color: textPrimary,
                                    fontSize: 18,
                                    height: 1),
                              ),
                              Text(
                                deskripsiApp.replaceAll('\n', ' '),
                                style: GoogleFonts.poppins(
                                  fontWeight: semibold,
                                  color: textPrimary,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const Spacer()
                    // SizedBox(
                    //   height: 23,
                    // ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: screen.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        ...gradientTertiary
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ButtonCard(
                                width: screen.width * 0.42,
                                height: 80,
                                background: Colors.green.shade200,
                                shadowColor: Colors.green.shade500,
                                splashColor: Colors.green.shade500,
                                onPress: () => {fullAbsensi()},
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(5000),
                                      ),
                                      child: FaIcon(
                                        FontAwesomeIcons.clipboardUser,
                                        color: Colors.green.shade900,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'Absensi',
                                      style: GoogleFonts.poppins(
                                        color: Colors.green.shade900,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ButtonCard(
                                width: screen.width * 0.42,
                                height: 80,
                                background: Colors.purple.shade200,
                                shadowColor: Colors.purple.shade500,
                                splashColor: Colors.purple.shade500,
                                onPress: () => {fullJurnal()},
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(5000),
                                      ),
                                      child: FaIcon(
                                        FontAwesomeIcons.book,
                                        color: Colors.purple.shade900,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'Jurnal',
                                      style: GoogleFonts.poppins(
                                        color: Colors.purple.shade900,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 40, left: 20, right: 20),
                                child: Text(
                                  historyAbsensiText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: semibold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 20,
                                ),
                                child: FutureBuilder(
                                  future: getAbsensi(),
                                  builder: (_, snapshot) {
                                    var historyAbsensi = snapshot.data;

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container(
                                        width: screen.width,
                                        height: 110,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    } else if (snapshot.hasData) {
                                      if (snapshot.data!.length > 0) {
                                        if (historyAbsensi!.length > 3) {
                                          historyAbsensi = historyAbsensi
                                              .toList()
                                              .sublist(0, 3);
                                        }
                                        return Row(
                                          children: [
                                            ...historyAbsensi.map((history) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                ),
                                                child: ButtonCard(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    width: screen.width * 0.7,
                                                    height: 110,
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 70,
                                                          height: 70,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: history
                                                                        .status ==
                                                                    'disetujui'
                                                                ? Colors.green
                                                                    .shade200
                                                                : history.status ==
                                                                        'ditolak'
                                                                    ? Colors.red
                                                                        .shade300
                                                                    : Colors
                                                                        .blue
                                                                        .shade300,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              999,
                                                            ),
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: FaIcon(
                                                            history.status ==
                                                                    'disetujui'
                                                                ? FontAwesomeIcons
                                                                    .check
                                                                : history.status ==
                                                                        'ditolak'
                                                                    ? FontAwesomeIcons
                                                                        .xmark
                                                                    : FontAwesomeIcons
                                                                        .clockRotateLeft,
                                                            color: Colors.white,
                                                            size: 30,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                DateFormat(
                                                                        'dd/MM/yyyy HH:mm:ss')
                                                                    .format(
                                                                      DateTime
                                                                          .fromMillisecondsSinceEpoch(
                                                                        history
                                                                            .createdAt,
                                                                      ),
                                                                    )
                                                                    .toString(),
                                                              ),
                                                              if (user!.role !=
                                                                  'siswa')
                                                                Text(
                                                                  history.user!
                                                                      .fullName,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .fade,
                                                                  softWrap:
                                                                      false,
                                                                  style: GoogleFonts
                                                                      .poppins(),
                                                                ),
                                                              Text(
                                                                'Absensi : ${history.absensi}',
                                                              ),
                                                              Text(
                                                                'Status : ${history.status ?? 'pending'}',
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  onPress: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      absensiRoute,
                                                      arguments:
                                                          user as UserModel,
                                                    );
                                                  },
                                                ),
                                              );
                                            }).toList(),
                                            if (historyAbsensi.length >= 3)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Button(
                                                  width: 70,
                                                  height: 70,
                                                  onPress: () {
                                                    fullAbsensi();
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          99999),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      blurStyle:
                                                          BlurStyle.outer,
                                                      offset:
                                                          const Offset(0, 3),
                                                      blurRadius: 9,
                                                      spreadRadius: -3,
                                                    )
                                                  ],
                                                  color: Colors.white,
                                                  splashColor: Colors.black
                                                      .withOpacity(0.2),
                                                  child: const FaIcon(
                                                    FontAwesomeIcons.angleRight,
                                                  ),
                                                ),
                                              )
                                          ],
                                        );
                                      } else {
                                        return Container(
                                          width: screen.width * 0.9,
                                          height: 110,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                  spreadRadius: -4,
                                                )
                                              ]),
                                          child: Text(
                                            "Belum ada data",
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      return Container(
                                        width: screen.width * 0.9,
                                        height: 110,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade300,
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                                spreadRadius: -4,
                                              )
                                            ]),
                                        child: Text(
                                          "Belum ada data",
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 20,
                                  right: 20,
                                ),
                                child: Text(
                                  historyJurnalText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: semibold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 20,
                                ),
                                child: FutureBuilder(
                                  future: getJurnal(),
                                  builder: (_, snapshot) {
                                    var historyJurnal = snapshot.data;
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container(
                                        width: screen.width,
                                        height: 110,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    } else if (snapshot.hasData) {
                                      if (snapshot.data!.length > 0) {
                                        if (historyJurnal!.length > 3) {
                                          historyJurnal = historyJurnal
                                              .toList()
                                              .sublist(0, 3);
                                        }
                                        return Row(
                                          children: [
                                            ...historyJurnal.map((history) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                ),
                                                child: ButtonCard(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    width: screen.width * 0.7,
                                                    height: 110,
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 70,
                                                          height: 70,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .green.shade200,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              999,
                                                            ),
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: const FaIcon(
                                                            FontAwesomeIcons
                                                                .piedPiper,
                                                            color: Colors.white,
                                                            size: 30,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                DateFormat(
                                                                        'dd/MM/yyyy HH:mm:ss')
                                                                    .format(DateTime
                                                                        .fromMillisecondsSinceEpoch(
                                                                      history
                                                                          .createdAt,
                                                                    ))
                                                                    .toString(),
                                                              ),
                                                              if (user!.role !=
                                                                  'siswa')
                                                                Text(
                                                                  history.user!
                                                                      .fullName,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .fade,

                                                                  softWrap:
                                                                      false,
                                                                  // maxLines: 2,
                                                                  style: GoogleFonts
                                                                      .poppins(),
                                                                ),
                                                              Text(
                                                                '${history.judul}',
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  onPress: () =>
                                                      {detailJurnal(history)},
                                                ),
                                              );
                                            }).toList(),
                                            if (historyJurnal.length >= 3)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Button(
                                                  width: 70,
                                                  height: 70,
                                                  onPress: () {
                                                    fullJurnal();
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          99999),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      blurStyle:
                                                          BlurStyle.outer,
                                                      offset:
                                                          const Offset(0, 3),
                                                      blurRadius: 9,
                                                      spreadRadius: -3,
                                                    )
                                                  ],
                                                  color: Colors.white,
                                                  splashColor: Colors.black
                                                      .withOpacity(0.2),
                                                  child: const FaIcon(
                                                    FontAwesomeIcons.angleRight,
                                                  ),
                                                ),
                                              )
                                          ],
                                        );
                                      } else {
                                        return Container(
                                          width: screen.width * 0.9,
                                          height: 110,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                  spreadRadius: -4,
                                                )
                                              ]),
                                          child: Text(
                                            "Belum ada data",
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      return Container(
                                        width: screen.width * 0.9,
                                        height: 110,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade300,
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                                spreadRadius: -4,
                                              )
                                            ]),
                                        child: Text(
                                          "Belum ada data",
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
