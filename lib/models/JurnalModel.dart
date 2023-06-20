// ignore_for_file: file_names

import 'package:e_jupe_skensa/models/UserModel.dart';

class JurnalModel {
  String uid;
  String judul;
  String deskripsi;
  int createdAt;
  int updatedAt;
  String userUid;
  UserModel? user;
  JurnalModel({
    required this.uid,
    required this.judul,
    required this.deskripsi,
    required this.createdAt,
    required this.updatedAt,
    required this.userUid,
    this.user,
  });
}
