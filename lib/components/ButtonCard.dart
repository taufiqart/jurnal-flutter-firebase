// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ButtonCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Color? background;
  final Color shadowColor;
  final Color splashColor;
  final Function onPress;
  const ButtonCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.background = Colors.white,
    this.shadowColor = Colors.grey,
    this.splashColor = Colors.white54,
    required this.onPress,
  });

  @override
  State<ButtonCard> createState() => _ButtonCardState();
}

class _ButtonCardState extends State<ButtonCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: widget.background,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor,
            blurStyle: BlurStyle.outer,
            offset: const Offset(0, 3),
            blurRadius: 9,
            spreadRadius: -3,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onPress();
          },
          splashColor: widget.splashColor,
          child: Container(
            alignment: Alignment.center,
            width: widget.width,
            height: widget.height,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
