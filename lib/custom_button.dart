import 'package:flutter/material.dart';

class KCustomButton extends StatelessWidget {
  final Widget widget;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final double? radius;
  final Color? borderColor;

  const KCustomButton(
      {Key? key,
      required this.widget,
      required this.onPressed,
      this.radius,
      this.borderColor,
      this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: borderColor ?? Colors.black12, width: 1),
            borderRadius: BorderRadius.circular(radius ?? 50)),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(radius ?? 50),
            child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(radius ?? 50),
                child: InkWell(
                    hoverColor: Colors.black.withOpacity(.05),
                    splashColor: Colors.white,
                    highlightColor: Colors.blue.shade300.withOpacity(.05),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 0),
                        child: widget),
                    onTap: onPressed,
                    onLongPress: onLongPress))));
  }
}
