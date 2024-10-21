import "package:flutter/material.dart";

enum AcquaInputType {
  text,
  password,
  dateTime,
}

class AcquaInput extends StatelessWidget {
  const AcquaInput({
    super.key, 
    this.xPadding = 8, 
    this.yPadding = 8, 
    required this.labelText, 
    this.gapPadding = 8, 
    this.inputType = AcquaInputType.text, 
    required this.controller
  });
  
  final String labelText;
  final double xPadding, yPadding;
  final double gapPadding;
  final AcquaInputType inputType;
  final TextEditingController controller;
  
  bool get _shouldObscure {
    return inputType == AcquaInputType.password;
  }

  bool get _shouldSuggest {
    return inputType != AcquaInputType.password;
  }

  bool get _shouldAutoCorrect {
    return inputType != AcquaInputType.password;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: xPadding, vertical: yPadding),
      child: TextField(
        obscureText: _shouldObscure,
        enableSuggestions: _shouldSuggest,
        autocorrect: _shouldAutoCorrect,
        controller: controller,
        decoration: InputDecoration(
          iconColor: Colors.white,
          border: OutlineInputBorder(
            gapPadding: gapPadding,
          ),
          labelText: labelText,
        )
      )
    );
  }
}
