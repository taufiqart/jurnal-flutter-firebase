// ignore_for_file: file_names

import 'package:e_jupe_skensa/models/UserModel.dart';

class AbsensiModel {
  String uid;
  String absensi;
  int createdAt;
  int updatedAt;
  String? status;
  String userUid;
  UserModel? user;
  AbsensiModel({
    required this.uid,
    required this.absensi,
    this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userUid,
    this.user,
  });
}
