import "package:flutter/material.dart";

class AcquaButton extends StatelessWidget {
  const AcquaButton({
    super.key, 
    required this.name, 
    required this.onPressed, 
    this.fontSize = 16, 
    this.xMargin = 0, 
    this.yMargin = 0, 
    this.xPadding = 0, 
    this.yPadding = 0, 
  });

  final String name;
  final double fontSize;
  final double xPadding, yPadding;
  final double xMargin, yMargin;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: xMargin, vertical: yMargin),
      child:  FilledButton(
        style:  FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: onPressed, 
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: xPadding, vertical: yPadding),
          child: Text(name,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      )
    );
  }
}
