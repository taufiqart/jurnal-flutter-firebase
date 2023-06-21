import 'package:e_jupe_skensa/config/variable.dart';
import 'package:e_jupe_skensa/firebase_options.dart';
import 'package:e_jupe_skensa/screens/LogIn.dart';
import 'package:e_jupe_skensa/screens/Onboarding.dart';
import 'package:e_jupe_skensa/screens/Screens.dart';
import 'package:e_jupe_skensa/screens/SignUp.dart';
import 'package:e_jupe_skensa/screens/absensi/Absensi.dart';
import 'package:e_jupe_skensa/screens/jurnal/DetailJurnal.dart';
import 'package:e_jupe_skensa/screens/jurnal/EditJurnal.dart';
import 'package:e_jupe_skensa/screens/jurnal/IsiJurnal.dart';
import 'package:e_jupe_skensa/screens/jurnal/Jurnal.dart';
import 'package:e_jupe_skensa/screens/profile/EditProfile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Hive.initFlutter();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ignore: unused_local_variable
  var userBox = await Hive.openBox('user');

  runApp(const MyApp());
  // FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var userBox = Hive.box('user');
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: nameApp,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // initialRoute: onboardingRoute,
      initialRoute: userBox.isEmpty ? onboardingRoute : homeRoute,
      routes: {
        homeRoute: (context) => const Screens(selectedIndex: 0),
        loginRoute: (context) => const LogIn(),
        signupRoute: (context) => const SignUp(),
        absensiRoute: (context) => const Absensi(),
        jurnalRoute: (context) => const Jurnal(),
        profileRoute: (context) => const Screens(selectedIndex: 1),
        onboardingRoute: (context) => const Onboarding(),
        isiJurnalRoute: (context) => const IsiJurnal(),
        detailJurnalRoute: (context) => const DetailJurnal(),
        editJurnalRoute: (context) => const EditJurnal(),
        editProfileRoute: (context) => const EditProfile(),
      },
    );
  }
}
