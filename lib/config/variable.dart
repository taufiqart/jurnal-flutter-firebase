// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';

// routes name
var absensiRoute = '/absensi';
var jurnalRoute = '/jurnal';
var isiJurnalRoute = '/isiJurnal';
var detailJurnalRoute = '/detailJurnal';
var editJurnalRoute = '/editJurnal';
var loginRoute = '/login';
var signupRoute = '/signup';
var onboardingRoute = '/onboarding';
var homeRoute = '/home';
var profileRoute = '/profile';
var editProfileRoute = '/editProfile';

// texts
var nameApp = 'E-JuPe Skensa Pas';
var deskripsiApp = 'Aplikasi Absensi dan\nJurnal Online';
var sloganApp = 'Pantau siswa pkl dengan\naplikasi e-jupe skensa pas';
var signupText = 'Daftar';
var loginText = 'Masuk';
var signoutText = 'Keluar';
var infoOnboardingText = 'Masuk atau Daftar untuk mengakses aplikasi';
var fullNameText = 'Nama Lengkap';
var passwordText = 'Password';
var emailText = 'Email';
var judulText = 'Judul';
var deskripsiText = 'Deskripsi';
var fullNameEmpty = 'nama lengkap harus diisi';
var passwordEmpty = 'password harus diisi';
var emailEmpty = 'email harus diisi';
var judulEmpty = 'judul harus diisi';
var deskripsiEmpty = 'deskripsi harus diisi';
var roleEmpty = 'harus diisi';
var roleText = 'Sebagai';
var signupAsText = 'Daftar sebagai';
var accountExistText = 'Sudah punya akun ';
var accountNotExistText = 'Belum punya akun ';
var jurnalText = 'Jurnal';
var absensiText = 'Absensi';
var historyAbsensiText = 'History Absensi';
var historyJurnalText = 'History Jurnal';
var isiJurnalText = 'Isi Jurnal';
var editJurnalText = 'Edit Jurnal';
var detailJurnalText = 'Detail Jurnal';
var submitText = 'Kirim';
var setujuText = 'Setuju';
var tolakText = 'Tolak';
var statusSetujuiText = 'disetujui';
var statusTolakText = 'ditolak';
var statusPendingText = 'pending';
var absenText = 'Absen';
var successDaftarText = 'Daftar berhasil';
var errorDaftarText = 'Daftar gagal';
var successMasukText = 'Masuk berhasil';
var errorMasukText = 'Masuk gagal';
var successHapusText = 'Berhasil dihapus';
var successEditText = 'Berhasil diedit';
var pulangText = 'pulang';
var masukText = 'masuk';
var siswaText = 'siswa';
var dataNotFoundText = 'Data tidak ditemukan';
var absensiNotFoundText = 'Absensi belum ada';
var absensiTimeout = 15;
var disableAbsenPulang =
    'Absen pulang akan aktif\nsetelah ${absensiTimeout} menit absen masuk';
var sudahAbsenText = 'Anda sudah absen\nsampai jumpa besok';
var jurnalFIlledText = 'Anda sudah mengisi jurnal\nisi lagi besok';
var hapusText = 'Hapus';
var editText = 'Edit';
var fromGalleryText = 'Buka galery';
var fromCameraText = 'Buka kamera';
var removeProfileText = 'Hapus foto';
var simpanText = 'Simpan';
var editProfileText = 'Edit Profile';
var greetingText = [
  'Selamat pagi.',
  'Selamat siang.',
  'Selamat sore.',
  'Selamat malam.'
];
List role = ['Siswa', 'Pembimbing', 'Humas'];

// var emailText = 'Email';
// colors
var gradientPrimary = [const Color(0xff618cff), const Color(0xffAEDDFF)];
var gradientSecondary = [Colors.blue.shade300, Colors.blue.shade200];
var gradientTertiary = [Colors.white, Colors.grey.shade200];
var gradientFour = [Colors.white, Colors.red.shade100];
var textPrimary = Colors.white;
var fieldPrimary = Colors.grey.shade600;
// fontsizes
var semibold = FontWeight.w600;

// enumerate
enum BtnType { fill, border }

// path
var logo = 'assets/images/logo.png';
var calendar = 'assets/images/calendar.png';
var waveAnimation = 'assets/animations/wave-lottie.json';
var loginAnimation = 'assets/animations/login-lottie.json';
var documentAnimation = 'assets/animations/document-lottie.json';
var defautlPic =
    'https://www.cornwallbusinessawards.co.uk/wp-content/uploads/2017/11/dummy450x450.jpg';
// var user = UserModel(
//   uid: 'sasa',
//   email: 'taufiqart@gmail.com',
//   fullName: 'MUKHAMMAD TAUFIQURROCHMAN',
//   profile:
//       'https://sps.widyatama.ac.id/wp-content/uploads/2020/08/dummy-profile-pic-female-300n300.jpg',
//   // password: 'alskalsasa',
//   role: 'pembimbing',
// );

// List<AbsensiModel> historyAbsensi = <AbsensiModel>[
//   AbsensiModel(
//     absensi: 'pulang',
//     createdAt: DateTime.now().millisecondsSinceEpoch,
//     updatedAt: DateTime.now().millisecondsSinceEpoch,
//     userUid: user.uid,
//     user: user,
//   ),
//   AbsensiModel(
//     absensi: 'masuk',
//     createdAt: DateTime.now().millisecondsSinceEpoch,
//     updatedAt: DateTime.now().millisecondsSinceEpoch,
//     userUid: user.uid,
//     status: 'disetujui',
//     user: user,
//   ),
//   AbsensiModel(
//     absensi: 'pulang',
//     createdAt: DateTime.now().millisecondsSinceEpoch,
//     updatedAt: DateTime.now().millisecondsSinceEpoch,
//     userUid: user.uid,
//     status: 'ditolak',
//     user: user,
//   ),
//   AbsensiModel(
//     absensi: 'masuk',
//     createdAt: DateTime.now().millisecondsSinceEpoch,
//     updatedAt: DateTime.now().millisecondsSinceEpoch,
//     userUid: user.uid,
//     status: 'ditolak',
//     user: user,
//   ),
// ];

// var userBox = Hive.box('user');
// var user = UserModel(
//   email: userBox.get('email'),
//   fullName: userBox.get('fullName'),
//   role: 'pembimbing',
//   uid: userBox.get('uid'),
//   profile: userBox.get('profile'),
// );

// List<JurnalModel> historyJurnal = <JurnalModel>[
//   JurnalModel(
//     uid: "sasassasa",
//     judul: 'Merakit Komputer',
//     deskripsi: 'Merakit komputer dengan bantuan pembimbing',
//     createdAt: DateTime.now().millisecondsSinceEpoch,
//     updatedAt: DateTime.now().millisecondsSinceEpoch,
//     userUid: user.uid,
//     user: user,
//   ),
//   JurnalModel(
//     uid: "dsdsdss",
//     judul: 'Entry data',
//     deskripsi: 'Memasukkan data ke database',
//     createdAt: DateTime.now().millisecondsSinceEpoch,
//     updatedAt: DateTime.now().millisecondsSinceEpoch,
//     userUid: user.uid,
//     user: user,
//   ),
// ];
