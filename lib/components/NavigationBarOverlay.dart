// ignore_for_file: file_names

import 'package:flutter/material.dart';

class NavigationBarOverlay extends StatefulWidget {
  final List items;
  final Widget page;
  const NavigationBarOverlay({
    super.key,
    required this.items,
    required this.page,
  });

  @override
  State<NavigationBarOverlay> createState() => _NavigationBarOverlayState();
}

class _NavigationBarOverlayState extends State<NavigationBarOverlay> {
  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Stack(
      children: [
        widget.page,
        Positioned(
          bottom: 0,
          child: Container(
            height: 55,
            width: screen.width,
            padding: const EdgeInsets.only(left: 20, right: 20),
            margin: const EdgeInsets.only(bottom: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                      spreadRadius: -3),
                ],
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [...widget.items],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
