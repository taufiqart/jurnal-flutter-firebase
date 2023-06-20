// ignore_for_file: sized_box_for_whitespace, prefer_typing_uninitialized_variables, file_names

import 'package:e_jupe_skensa/config/variable.dart';
import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final type;
  final child;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final colors;
  final color;
  final borderColor;
  final splashColor;
  final bool enabled;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;

  final Function onPress;

  const Button({
    super.key,
    this.type = BtnType.fill,
    this.width,
    this.child,
    this.height,
    this.borderRadius,
    this.colors,
    this.color,
    this.borderColor,
    this.borderWidth = 2,
    this.boxShadow,
    this.splashColor,
    this.enabled = true,
    required this.onPress,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: widget.type == BtnType.fill && widget.color == null
                  ? LinearGradient(
                      colors: widget.colors ?? gradientPrimary,
                    )
                  : LinearGradient(
                      colors: [
                        widget.color ?? Colors.transparent,
                        widget.color ?? Colors.transparent
                      ],
                    ),
              border: widget.type == BtnType.border
                  ? Border.all(
                      color: widget.borderColor ?? Colors.blue,
                      width: widget.borderWidth)
                  : null,
              borderRadius: widget.borderRadius,
              boxShadow: widget.boxShadow,
            ),
          ),
          Positioned.fill(
            child: Material(
              borderRadius: widget.borderRadius,
              clipBehavior: Clip.antiAlias,
              color: widget.enabled ? Colors.transparent : Colors.grey.shade400,
              child: InkWell(
                splashColor: widget.enabled
                    ? widget.splashColor ?? Colors.white54
                    : Colors.transparent,
                onTap: () {
                  widget.enabled ? widget.onPress() : () {};
                },
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  alignment: Alignment.center,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
