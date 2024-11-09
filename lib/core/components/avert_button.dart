import "package:flutter/material.dart";

class AvertButton extends StatelessWidget {
  const AvertButton({
    super.key, 
    required this.name, 
    required this.onPressed, 
    this.fontSize = 16, 
    this.xMargin = 0, 
    this.yMargin = 0, 
    this.xPadding = 8, 
    this.yPadding = 8, 
    this.bgColor,
    this.fgColor,
  });

  final String name;
  final double fontSize;
  final double xPadding, yPadding;
  final double xMargin, yMargin;
  final VoidCallback? onPressed;
  final Color? bgColor, fgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: xMargin, vertical: yMargin),
      child:  FilledButton(
        style:  FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: xPadding, vertical: yPadding),
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: onPressed, 
        child: Text(name,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
      )
    );
  }
}
