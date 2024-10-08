import "package:flutter/material.dart";

class InputField extends StatelessWidget {
  const InputField({super.key, required this.padding, required this.labelText, this.gapPadding = 8, required this.controller});
  
  final EdgeInsetsGeometry padding;
  final String labelText;
  final double gapPadding;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            gapPadding: gapPadding,
          ),
          labelText: labelText,
        )
      )
    );
  }
}
