import "package:flutter/material.dart";

class AcquaButton extends StatelessWidget {
  const AcquaButton({super.key, required this.buttonName, required this.onPressed});

  final String buttonName;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          right: 8.0,
          left: 8.0,
        ),
        child: FilledButton(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: onPressed, 
          child: Text(buttonName),
        )
      )
    );
  }
}
