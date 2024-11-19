import "package:flutter/material.dart";

class AvertButton extends StatelessWidget {
  const AvertButton({
    super.key, 
    required this.name, 
    required this.onPressed, 
    this.fontSize   = 16,
    double xMargin  = 0,
    double yMargin  = 0,
    double xPadding = 8,
    double yPadding = 8,
    this.bgColor,
    this.fgColor,
  }):
    pLeft = xPadding, pRight = xPadding, pTop = yPadding, pBottom = yPadding,
    mLeft = xMargin, mRight = xMargin, mTop = yMargin, mBottom = yMargin
  ;

  const AvertButton.flex({
    super.key,
    required this.name,
    required this.onPressed,
    this.fontSize = 16,
    this.mLeft    = 0,
    this.mRight   = 0,
    this.mTop     = 0,
    this.mBottom  = 0,
    this.pLeft    = 8,
    this.pRight   = 8,
    this.pTop     = 8,
    this.pBottom  = 8,
    this.bgColor,
    this.fgColor,
  });

  final String name;
  final double fontSize;
  final double pLeft, pRight, pTop, pBottom;
  final double mLeft, mRight, mTop, mBottom;
  final VoidCallback? onPressed;
  final Color? bgColor, fgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top:    mTop,
        bottom: mBottom,
        left:   mLeft,
        right:  mRight,
      ),
      child:  FilledButton(
        style:  FilledButton.styleFrom(
          padding: EdgeInsets.only(
            top:    pTop,
            bottom: pBottom,
            left:   pLeft,
            right:  pRight,
          ),
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
