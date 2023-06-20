// ignore_for_file: file_names

import 'package:flutter/material.dart';

class NavigationBarOverlayItem extends StatefulWidget {
  final bool selected;
  final Function onPress;
  final Widget? child;
  const NavigationBarOverlayItem({
    super.key,
    required this.selected,
    required this.onPress,
    this.child,
  });

  @override
  State<NavigationBarOverlayItem> createState() =>
      _NavigationBarOverlayItemState();
}

class _NavigationBarOverlayItemState extends State<NavigationBarOverlayItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween<double>(begin: -15, end: 0).animate(_animationController)
      ..addStatusListener(
        (status) {
          return print('halo');
        },
      );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.selected ? -15 - _animation.value : 0),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: widget.selected ? Colors.grey : Colors.transparent,
                    blurRadius: 6,
                    blurStyle: BlurStyle.outer,
                    spreadRadius: -4,
                    offset: const Offset(0, 4),
                  )
                ]),
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _animationController.stop();
                  _animationController.forward();
                  widget.onPress();
                },
                child: Container(
                  alignment: Alignment.center,
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
