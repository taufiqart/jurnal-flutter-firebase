// ignore_for_file: prefer_typing_uninitialized_variables, prefer_const_constructors, file_names

import 'package:e_jupe_skensa/components/NavigationBarOverlay.dart';
import 'package:e_jupe_skensa/components/NavigationBarOverlayItem.dart';
import 'package:e_jupe_skensa/config/variable.dart';
import 'package:e_jupe_skensa/screens/Home.dart';
import 'package:e_jupe_skensa/screens/profile/Profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Screens extends StatefulWidget {
  final int selectedIndex;
  const Screens({super.key, this.selectedIndex = 0});

  @override
  State<Screens> createState() => _ScreensState();
}

class _ScreensState extends State<Screens> with SingleTickerProviderStateMixin {
  var _selectedIndex;
  @override
  void initState() {
    _selectedIndex = widget.selectedIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      var userBox = Hive.box('user');

      if (userBox.isEmpty ||
          userBox.get('uid') == null ||
          userBox.get('email') == null ||
          userBox.get('role') == null ||
          userBox.get('profile') == null ||
          userBox.get('fullName') == null) {
        Navigator.pushReplacementNamed(context, onboardingRoute);
      }
    });
    return NavigationBarOverlay(
      items: [
        NavigationBarOverlayItem(
          selected: _selectedIndex == 0,
          onPress: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
          child: FaIcon(
            FontAwesomeIcons.house,
            color: Colors.cyan.shade300,
          ),
        ),
        NavigationBarOverlayItem(
          selected: _selectedIndex == 1,
          onPress: () {
            setState(() {
              _selectedIndex = 1;
            });
          },
          child: FaIcon(
            FontAwesomeIcons.userLarge,
            color: Colors.cyan.shade300,
          ),
        ),
      ],
      page: [Home(), Profile()][_selectedIndex],
    );
  }
}
