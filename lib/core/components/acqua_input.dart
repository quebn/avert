import "package:flutter/material.dart";
import "package:acqua/core/utils.dart";

enum AcquaInputType {
  text,
  password,
  datetime,
}

class AcquaInput extends StatefulWidget {
  const AcquaInput({
    super.key, 
    required this.labelText, 
    required this.controller,
    this.xPadding = 8, 
    this.yPadding = 8, 
    this.gapPadding = 8, 
    this.inputType = AcquaInputType.text, 
    this.validateEmpty = false, 
    this.validator,
  });

  const AcquaInput.password({
    super.key, 
    required this.controller,
    required this.validator,
    this.xPadding = 8, 
    this.yPadding = 8, 
    this.gapPadding = 8, 
    this.labelText = "Password", 
  }) : inputType = AcquaInputType.password, validateEmpty = true ;

  final String labelText;
  final double xPadding, yPadding;
  final double gapPadding;
  final AcquaInputType inputType;
  final TextEditingController controller;
  final bool validateEmpty;
  final String? Function(String value)? validator;
  
  @override
  State<StatefulWidget> createState() => _InputState();
}

class _InputState extends State<AcquaInput> {

  bool shouldObscure = true;
  String? errMsg;
  //Strig shouldObscure = true;

  @override
  Widget build(BuildContext context) {
    switch(widget.inputType) {
      case AcquaInputType.password:
        return password(context);
      default:
        return text(context);
    }
  }

  Widget text(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: widget.xPadding, vertical: widget.yPadding),
    child: TextField(
      onEditingComplete: () => validate(context),
      controller: widget.controller,
      decoration: InputDecoration(
        iconColor: Colors.white,
        border: OutlineInputBorder(
          gapPadding: widget.gapPadding,
        ),
        labelText: widget.labelText,
        errorText: errMsg,
      )
    )
  );

  Widget password(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: widget.xPadding, vertical: widget.yPadding),
    child: TextField(
      onEditingComplete: () => validate(context),
      obscureText: shouldObscure,
      enableSuggestions: false,
      autocorrect: false,
      controller: widget.controller,
      decoration: InputDecoration(
        suffixIcon: showButton(context),
        iconColor: Colors.white,
        border: OutlineInputBorder(
          gapPadding: widget.gapPadding,
        ),
        labelText: widget.labelText,
        errorText: errMsg,
      )
    )
  );

  Widget showButton(BuildContext context) => IconButton(
    //padding: EdgeInsets.all(0),
    iconSize: 28,
    isSelected: shouldObscure,
    icon: const Icon(Icons.visibility_off_rounded),
    selectedIcon: const Icon(Icons.visibility_rounded),
    onPressed: () {
      setState(() {
        shouldObscure = !shouldObscure;
      });
    },
  );

  void validate(BuildContext context) {
    setState(() {
      if (widget.validateEmpty) {
        errMsg = widget.controller.text.isEmpty ? "${widget.labelText} field must not be empty!" : null;
        return;
      }
      errMsg = widget.validator!(widget.controller.text);
    });
    printLog("errMsg: $errMsg", level:LogLevel.warn);
    if (errMsg == null) {
      FocusScope.of(context).unfocus();
    }
  }
}
