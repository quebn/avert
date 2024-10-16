import "package:flutter/material.dart";

enum AcquaInputType {
  text,
  password,
  dateTime,
}

class AcquaInput extends StatelessWidget {
  const AcquaInput({
    super.key, 
    required this.padding, 
    required this.labelText, 
    this.gapPadding = 8, 
    this.inputType = AcquaInputType.text, 
    required this.controller
  });
  
  final EdgeInsetsGeometry padding;
  final String labelText;
  final double gapPadding;
  final AcquaInputType inputType;
  final TextEditingController controller;
  
  bool get _shouldObscure {
    switch (inputType) {
      case AcquaInputType.password:
        return true;
      default:
        return false;
    }
  }

  bool get _shouldSuggest {
    switch (inputType) {
      case AcquaInputType.password:
        return false;
      default:
        return true;
    }
  }

  bool get _shouldAutoCorrect {
    switch (inputType) {
      case AcquaInputType.password:
        return false;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        obscureText: _shouldObscure,
        enableSuggestions: _shouldSuggest,
        autocorrect: _shouldAutoCorrect,
        controller: controller,
        decoration: InputDecoration(
          //filled: true,
          //fillColor: Colors.black,
          iconColor: Colors.white,
          border: OutlineInputBorder(
            gapPadding: gapPadding,
            //borderSide: BorderSide(width:5, color:Colors.red)
          ),
          labelText: labelText,
        )
      )
    );
  }

}
