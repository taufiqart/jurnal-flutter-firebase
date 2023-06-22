// ignore_for_file: avoid_unnecessary_containers, sized_box_for_whitespace, prefer_is_empty, await_only_futures

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_jupe_skensa/components/Button.dart';
import 'package:e_jupe_skensa/components/ButtonCard.dart';
import 'package:e_jupe_skensa/config/variable.dart';
import 'package:e_jupe_skensa/models/JurnalModel.dart';
import 'package:e_jupe_skensa/models/UserModel.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Stack;
import 'package:toast/toast.dart';

class Jurnal extends StatefulWidget {
  const Jurnal({super.key});

  @override
  State<Jurnal> createState() => _JurnalState();
}

class _JurnalState extends State<Jurnal> {
  var absen = true;
  var today = false;
  var loading = true;
  var jurnal = true;
  var timer;
  var _textSearch = '';
  Iterable<JurnalModel?>? globalJurnal;
  UserModel? user;
  @override
  void initState() {
    var userBox = Hive.box('user');
    // user = ModalRoute.of(context)!.settings.arguments as UserModel;
    user = UserModel(
      uid: userBox.get('uid'),
      fullName: userBox.get('fullName'),
      email: userBox.get('email'),
      role: userBox.get('role'),
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

  void detailJurnal(jurnal) {
    Navigator.pushNamed(context, detailJurnalRoute,
        arguments: jurnal as JurnalModel);
  }

  void hapusJurnal(jurnal) async {
    if (await confirm(
      context,
      title: const Text('Hapus'),
      content: const Text('Yakin ingin menghapus?'),
      textOK: Container(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.red.shade300,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Hapus',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          const SizedBox(width: 6),
          const FaIcon(
            FontAwesomeIcons.trash,
            size: 12,
            color: Colors.white,
          )
        ]),
      ),
      textCancel: Container(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
        width: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blue.shade300,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          'Batal',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    )) {
      var db = FirebaseFirestore.instance;
      await db.collection('jurnal').doc(jurnal.uid).delete().then((value) {
        Toast.show(
          successHapusText,
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
          jurnal;
        });
      });
    }
  }

  void editJurnal(jurnal) {
    Navigator.pushNamed(context, editJurnalRoute, arguments: jurnal);
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

  Future<Iterable<JurnalModel>> getJurnal(textSearch) async {
    var userBox = Hive.box('user');
    var db = FirebaseFirestore.instance;
    Future<Iterable<JurnalModel>> siswa() async {
      var jurnalRef = await db
          .collection('jurnal')
          .orderBy('createdAt', descending: true)
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
      jurnals =
          jurnals.where((element) => element.userUid == userBox.get('uid'));
      if (DateTime.fromMillisecondsSinceEpoch(jurnals.first.createdAt).day ==
          DateTime.now().day) {
        setState(() {
          today = true;
          jurnal = false;
        });
      } else {
        setState(() {
          today = false;
          jurnal = true;
        });
      }

      return jurnals;
    }

    Future<Iterable<JurnalModel>> other() async {
      var users = await getUsers();
      var jurnalRef = await db
          .collection('jurnal')
          .orderBy('createdAt', descending: true)
          .get();
      var jurnals = await jurnalRef.docs.map((data) {
        UserModel? user;
        for (var tmpUser in users) {
          if (data.data()['userUid'] == tmpUser.uid) {
            user = tmpUser;
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

      if (textSearch != '') {
        jurnals = jurnals.where(
          (element) => element.user!.fullName
              .toLowerCase()
              .contains(textSearch.toLowerCase()),
        );
      }

      return jurnals;
    }

    if (user!.role == 'siswa') {
      return await siswa();
    } else {
      return await other();
    }
  }

  void cetakData() async {
    var managestorage = await Permission.manageExternalStorage.status;
    var storage = await Permission.storage.status;
    if (storage.isGranted && managestorage.isGranted) {
      if (globalJurnal != null) {
        final Workbook workbook = Workbook();
        final Worksheet sheet = workbook.worksheets[0];

        List<ExcelDataRow> _buildReportDataRows() {
          List<ExcelDataRow> excelDataRows = <ExcelDataRow>[];

          excelDataRows = globalJurnal!.map<ExcelDataRow>((dataRow) {
            return ExcelDataRow(cells: <ExcelDataCell>[
              ExcelDataCell(
                columnHeader: 'Nama Lengkap',
                value: dataRow?.user!.fullName,
              ),
              ExcelDataCell(
                columnHeader: 'Judul',
                value: dataRow?.judul,
              ),
              ExcelDataCell(
                  columnHeader: 'Deskripsi', value: dataRow?.deskripsi),
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

        var fileName = DateTime.now()
            .toString()
            .replaceAll(':', '')
            .replaceAll(' ', '_')
            .split('.')[0];
        final String filePath = '${path}/Jurnal-${fileName}.xlsx';
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
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      } else if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
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
  Widget build(BuildContext context) {
    ToastContext().init(context);
    if (TickerMode.of(context)) {
      setState(() {});
    }
    var screen = MediaQuery.of(context).size;
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
                              isiJurnalText,
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
                        user!.role != 'siswa'
                            ? Material(
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
                              )
                            : Material(
                                color: Colors.grey.shade300.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(99999),
                                clipBehavior: Clip.antiAlias,
                              )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            user!.role == 'siswa'
                ? jurnal
                    ? Container(
                        height: screen.height * 0.14,
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
                          gradient: LinearGradient(colors: gradientFour),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.red.shade100,
                            onTap: () {
                              Navigator.pushNamed(context, isiJurnalRoute);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.piedPiper,
                                    size: 35,
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    isiJurnalText,
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: semibold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
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
                            colors: gradientFour,
                          ),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            jurnalFIlledText,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: semibold,
                              color: Colors.grey.shade700,
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
                    future: getJurnal(_textSearch),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var historyJurnal = snapshot.data;
                        if (snapshot.data!.length > 0) {
                          globalJurnal = snapshot.data;
                          return Column(
                            children: [
                              ...historyJurnal!
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                // ignore: unused_local_variable
                                var idx = entry.key;
                                var history = entry.value;

                                // ignore: unnecessary_null_comparison
                                if (history != null) {
                                  globalJurnal = snapshot.data;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    child: ButtonCard(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                          top: 10,
                                          left: 10,
                                          bottom: 10,
                                        ),
                                        constraints: const BoxConstraints(
                                          maxHeight: 90,
                                          minHeight: 70,
                                        ),
                                        // width: screen.width * 0.7,
                                        // height: 110,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  999,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: const FaIcon(
                                                FontAwesomeIcons.piedPiper,
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
                                                  if (user!.role != 'siswa')
                                                    Text(
                                                      history.user!.fullName,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      softWrap: false,
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                  Text(
                                                    history.judul,
                                                  ),
                                                  if (user!.role == 'siswa')
                                                    Container(
                                                      height: 30,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 10),
                                                        child: Row(
                                                          children: [
                                                            const Spacer(),
                                                            Button(
                                                              onPress: () {
                                                                editJurnal(
                                                                    history);
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
                                                                editText,
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
                                                              onPress: () {
                                                                hapusJurnal(
                                                                    history);
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
                                                                hapusText,
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
                                      onPress: () {
                                        detailJurnal(history);
                                      },
                                    ),
                                  );
                                } else {
                                  globalJurnal = null;
                                  loading = false;
                                  return Center(
                                    child: Container(
                                      child: Text(
                                        dataNotFoundText,
                                        style:
                                            GoogleFonts.poppins(fontSize: 18),
                                      ),
                                    ),
                                  );
                                }
                              }).toList(),
                            ],
                          );
                        } else {
                          globalJurnal = null;
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
                        globalJurnal = null;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (_textSearch != '' && snapshot.data == null) {
                        loading = false;
                        globalJurnal = null;
                        return Center(
                            child: Container(
                          child: Text(
                            dataNotFoundText,
                            style: GoogleFonts.poppins(fontSize: 18),
                          ),
                        ));
                      } else {
                        jurnal = true;
                        globalJurnal = null;
                        return Center(
                          child: Container(
                            child: Text(
                              dataNotFoundText,
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
