// ignore_for_file: prefer_typing_uninitialized_variables, await_only_futures, unnecessary_brace_in_string_interps, prefer_is_empty, avoid_unnecessary_containers, file_names, unused_element

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_jupe_skensa/components/Button.dart';
import 'package:e_jupe_skensa/components/ButtonCard.dart';
import 'package:e_jupe_skensa/config/variable.dart';
import 'package:e_jupe_skensa/models/AbsensiModel.dart';
import 'package:e_jupe_skensa/models/UserModel.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Stack, Row;
import 'package:open_file/open_file.dart';
import 'package:toast/toast.dart';

class Absensi extends StatefulWidget {
  const Absensi({super.key});

  @override
  State<Absensi> createState() => _AbsensiState();
}

class _AbsensiState extends State<Absensi> {
  var db = FirebaseFirestore.instance;
  // List<AbsensiModel>? historyAbsensi;
  var _textSearch = '';
  var lastAbsen = 'masuk';
  var absen = true;
  var today = false;
  var loading = true;
  var timer;
  Iterable<AbsensiModel?>? globalAbsensis;
  var userBox = Hive.box('user');

  void confirmAbsensi(absensi, status) async {
    var db = FirebaseFirestore.instance;
    await db.collection('absensi').doc(absensi.uid).update({'status': status});
    setState(() {
      _textSearch;
    });
  }

  void absensi(absensi) async {
    // ignore: unused_local_variable
    var absen = await db.collection('absensi').add({
      "absensi": absensi,
      "status": statusPendingText,
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "updatedAt": DateTime.now().millisecondsSinceEpoch,
      "userUid": userBox.get('uid')
    });

    setState(() {
      _textSearch;
    });
  }

  Future<Iterable<AbsensiModel?>> getAbsensi(textSearch) async {
    var db = FirebaseFirestore.instance;
    var absensiRef = await db
        .collection('absensi')
        .orderBy('createdAt', descending: true)
        .get();
    var userRef = await db.collection('users').get();
    var users = await userRef.docs.map((data) {
      return UserModel(
        uid: data.id,
        fullName: data.data()['fullName'],
        email: data.data()['email'],
        role: data.data()['role'],
      );
    });

    var absensis = await absensiRef.docs.map((data) {
      UserModel? userAbsen;
      for (var tmpUser in users) {
        if (data.data()['userUid'] == tmpUser.uid) {
          userAbsen = tmpUser;
          continue;
        }
      }
      if (userAbsen != null) {
        return AbsensiModel(
          uid: data.id,
          status: data.data()['status'],
          absensi: data.data()['absensi'],
          createdAt: data.data()['createdAt'],
          updatedAt: data.data()['updatedAt'],
          userUid: data.data()['userUid'],
          user: userAbsen,
        );
      }
      return null;
    });

    if (userBox.get('role') == 'siswa') {
      absensis =
          absensis.where((element) => element!.userUid == userBox.get('uid'));
    }

    if (textSearch != '') {
      absensis = absensis.where(
        (element) =>
            element!.user!.fullName
                .toLowerCase()
                .contains(textSearch.toLowerCase()) ||
            element.status!.contains(
              textSearch.toLowerCase(),
            ),
      );
    }

    setState(() {
      if (DateTime.fromMillisecondsSinceEpoch(absensis.toList()[0]!.createdAt)
              .day ==
          DateTime.now().day) {
        if (absensis.toList()[0]!.absensi == masukText) {
          today = true;
          if (absensis.toList()[0]!.createdAt + (absensiTimeout * 60 * 1000) <=
              DateTime.now().millisecondsSinceEpoch) {
            timer = absensis.toList()[0]!.createdAt +
                (absensiTimeout * 60 * 1000) -
                DateTime.now().millisecondsSinceEpoch;
            lastAbsen = pulangText;
            absen = true;
          }
        } else {
          lastAbsen = masukText;
          absen = false;
          today = true;
        }
      } else {
        today = false;
        absen = true;
        lastAbsen = masukText;
      }
    });

    return absensis;
  }

  void cetakData() async {
    var managestorage = await Permission.manageExternalStorage;
    var storage = await Permission.storage.request();
    if (await managestorage.isGranted) {
      if (globalAbsensis != null) {
        final Workbook workbook = Workbook();
        final Worksheet sheet = workbook.worksheets[0];

        List<ExcelDataRow> _buildReportDataRows() {
          List<ExcelDataRow> excelDataRows = <ExcelDataRow>[];

          excelDataRows = globalAbsensis!.map<ExcelDataRow>((dataRow) {
            return ExcelDataRow(cells: <ExcelDataCell>[
              ExcelDataCell(
                columnHeader: 'Nama Lengkap',
                value: dataRow?.user!.fullName,
              ),
              ExcelDataCell(
                columnHeader: 'Absensi',
                value: dataRow?.absensi,
              ),
              ExcelDataCell(columnHeader: 'Status', value: dataRow?.status),
              ExcelDataCell(
                columnHeader: 'Tanggal',
                value: DateFormat('dd/MM/yyyy HH:mm:ss')
                    .format(
                      DateTime.fromMillisecondsSinceEpoch(
                        dataRow!.createdAt,
                      ),
                    )
                    .toString(),
              )
            ]);
          }).toList();

          return excelDataRows;
        }

        final List<ExcelDataRow> dataRows = _buildReportDataRows();
        sheet.importData(dataRows, 1, 1);

        final List<int> bytes = workbook.saveAsStream();
        workbook.dispose();
        final String path =
            await ExternalPath.getExternalStoragePublicDirectory(
                ExternalPath.DIRECTORY_DOCUMENTS);

        var fileName =
            DateTime.now().toString().replaceAll(' ', '_').split('.')[0];
        final String filePath = '${path}/absensi-${fileName}.xlsx';
        await File(filePath).create(recursive: true);
        final File file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);
        print(path);
        Toast.show(
          'File Berada di folder Documents',
          duration: 2,
          backgroundColor: Colors.white,
          gravity: Toast.bottom,
          rootNavigator: false,
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.black,
          ),
        );

        Future.delayed(Duration(seconds: 1), () {
          OpenFile.open(filePath);
        });
      } else {
        Toast.show(
          'Data tidak ada',
          duration: 2,
          backgroundColor: Colors.white,
          gravity: Toast.bottom,
          rootNavigator: false,
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.black,
          ),
        );
      }
    } else {
      await Permission.manageExternalStorage.request();
      Toast.show(
        'Ijinkan mengakses penyimpanan',
        duration: 2,
        backgroundColor: Colors.white,
        gravity: Toast.bottom,
        rootNavigator: false,
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          color: Colors.black,
        ),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = ModalRoute.of(context)!.settings.arguments as UserModel;
    // print(user);

    var screen = MediaQuery.of(context).size;
    if (TickerMode.of(context)) {
      setState(() {});
    }
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    ToastContext().init(context);
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
                              absensiText,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        Material(
                          color: Colors.grey.shade300.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(99999),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            splashColor: Colors.white54,
                            onTap: () => {cetakData()},
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              child: FaIcon(
                                FontAwesomeIcons.print,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            (user.role == siswaText)
                ? absen
                    ? (today && lastAbsen == pulangText) ||
                            (lastAbsen == masukText && !today)
                        ? Container(
                            height: screen.height * 0.16,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 40),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade500,
                                  blurRadius: 10,
                                  spreadRadius: -5,
                                  offset: const Offset(0, 5),
                                  blurStyle: BlurStyle.outer,
                                )
                              ],
                              gradient: LinearGradient(
                                colors: gradientSecondary,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.blue.shade100,
                                onTap: () {
                                  absensi(lastAbsen);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${absenText} ${lastAbsen.toUpperCase()[0]}${lastAbsen.toLowerCase().substring(1)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: semibold,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: screen.height * 0.16,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 40),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade500,
                                  blurRadius: 10,
                                  spreadRadius: -5,
                                  offset: const Offset(0, 5),
                                  blurStyle: BlurStyle.outer,
                                )
                              ],
                              gradient: LinearGradient(
                                colors: gradientSecondary,
                              ),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                disableAbsenPulang,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: semibold,
                                  color: Colors.blue.shade900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                    : Container(
                        height: screen.height * 0.16,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 40),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade500,
                              blurRadius: 10,
                              spreadRadius: -5,
                              offset: const Offset(0, 5),
                              blurStyle: BlurStyle.outer,
                            )
                          ],
                          gradient: LinearGradient(
                            colors: gradientSecondary,
                          ),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            sudahAbsenText,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: semibold,
                              color: Colors.blue.shade900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Column(
                      children: [
                        Container(
                          width: screen.width * 0.8,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                        left: 20, right: 10),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    hintText: 'Nama...',
                                    hintStyle: GoogleFonts.poppins(
                                      color: fieldPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _textSearch = value;
                                    });
                                  },
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.blue,
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(right: 10),
                                    child: const FaIcon(
                                      FontAwesomeIcons.magnifyingGlass,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            Expanded(
              child: Container(
                width: screen.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  child: FutureBuilder(
                    future: getAbsensi(_textSearch),
                    builder: (context, snapshot) {
                      // print(snapshot.data[0]['status']);
                      if (snapshot.hasData) {
                        loading = false;
                        if (snapshot.data!.length > 0) {
                          globalAbsensis =
                              snapshot.data as Iterable<AbsensiModel?>?;
                          loading = false;
                          return Column(
                            children: [
                              ...snapshot.data!.map((history) {
                                if (history != null) {
                                  loading = false;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    child: ButtonCard(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                          top: 10,
                                          // left: 10,
                                          bottom: 10,
                                        ),
                                        width: screen.width * 0.7,
                                        // height: 110,
                                        constraints: const BoxConstraints(
                                          maxHeight: 110,
                                          minHeight: 70,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: history.status ==
                                                        statusSetujuiText
                                                    ? Colors.green.shade200
                                                    : history.status ==
                                                            statusTolakText
                                                        ? Colors.red.shade300
                                                        : Colors.blue.shade300,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  999,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: FaIcon(
                                                history.status ==
                                                        statusSetujuiText
                                                    ? FontAwesomeIcons.check
                                                    : history.status ==
                                                            statusTolakText
                                                        ? FontAwesomeIcons.xmark
                                                        : FontAwesomeIcons
                                                            .clockRotateLeft,
                                                color: Colors.white,
                                                size: 25,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Expanded(
                                              // width: screen.width * 0.45,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    DateFormat(
                                                            'dd/MM/yyyy HH:mm:ss')
                                                        .format(
                                                          DateTime
                                                              .fromMillisecondsSinceEpoch(
                                                            history.createdAt,
                                                          ),
                                                        )
                                                        .toString(),
                                                  ),
                                                  if (user.role != 'siswa')
                                                    Text(
                                                      history.user!.fullName,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      softWrap: false,
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                  Text(
                                                    '${absensiText} : ${history.absensi}',
                                                  ),
                                                  const SizedBox(height: 5),
                                                  if (user.role == 'pembimbing')
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 10),
                                                        child: Row(
                                                          children: [
                                                            const Spacer(),
                                                            Button(
                                                              enabled: history
                                                                      .status !=
                                                                  statusSetujuiText,
                                                              onPress: () {
                                                                confirmAbsensi(
                                                                    history,
                                                                    statusSetujuiText);
                                                              },
                                                              color: Colors
                                                                  .green
                                                                  .shade300,
                                                              width: 80,
                                                              // height: 0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              child: Text(
                                                                setujuText,
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Button(
                                                              enabled: history
                                                                      .status !=
                                                                  statusTolakText,
                                                              onPress: () {
                                                                confirmAbsensi(
                                                                    history,
                                                                    statusTolakText);
                                                              },
                                                              color: Colors
                                                                  .red.shade300,
                                                              width: 80,
                                                              // height: 0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              child: Text(
                                                                tolakText,
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  color: Colors
                                                                      .white,
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
                                          ],
                                        ),
                                      ),
                                      onPress: () {},
                                    ),
                                  );
                                } else {
                                  loading = false;
                                  globalAbsensis = null;
                                  return Container(
                                    child: Text(
                                      dataNotFoundText,
                                      style: GoogleFonts.poppins(fontSize: 18),
                                    ),
                                  );
                                }
                              })
                            ],
                          );
                        } else {
                          globalAbsensis = null;
                          loading = false;
                          return Center(
                            child: Container(
                              child: Text(
                                dataNotFoundText,
                                style: GoogleFonts.poppins(fontSize: 18),
                              ),
                            ),
                          );
                        }
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        globalAbsensis = null;
                        loading = true;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (_textSearch != '' && snapshot.data == null) {
                        globalAbsensis = null;
                        loading = false;
                        return Center(
                            child: Container(
                          child: Text(
                            dataNotFoundText,
                            style: GoogleFonts.poppins(fontSize: 18),
                          ),
                        ));
                      } else {
                        globalAbsensis = null;
                        loading = false;
                        return Center(
                          child: Container(
                            child: Text(
                              absensiNotFoundText,
                              style: GoogleFonts.poppins(fontSize: 18),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
