import "package:flutter/gestures.dart";
import "package:flutter/material.dart";


class AvertLink extends StatelessWidget {
  const AvertLink({super.key,
    required this.linkText, 
    required this.onPressed, 
    this.linkSize = 14, 
    this.xMargin = 8,
    this.yMargin = 8,
    //this.xPadding = 8,
    //this.yPadding = 8,
  });

  final String linkText;
  final double linkSize;
  final double xMargin, yMargin;
  //final double xPadding, yPadding;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: xMargin, vertical: yMargin),
      child: Center(
        child: RichText(
          text: TextSpan(
            recognizer: TapGestureRecognizer()..onTap = onPressed,
            text: linkText,
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.black,
              fontSize: linkSize,
              fontWeight: FontWeight.bold,
            )
          )
        ),
      )
    );
  }
}
