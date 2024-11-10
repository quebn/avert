import "package:flutter/material.dart";
import "package:avert/core/utils.dart";
import "package:flutter/services.dart";

enum AvertInputType {
  text,
  alphanumeric,
  password,
  datetime,
}

class AvertInput extends StatefulWidget {
  const AvertInput({
    super.key,
    required this.name,
    required this.controller,
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8,
    this.inputType = AvertInputType.text,
    this.required = false,
    this.validator,
    this.forceErrMsg,
    this.onChanged,
  });

  const AvertInput.alphanumeric({
    super.key, 
    required this.name, 
    required this.controller,
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8, 
    this.required = false,
    this.validator,
    this.forceErrMsg,
    this.onChanged,
  }) : inputType = AvertInputType.alphanumeric;

  const AvertInput.password({
    super.key, 
    required this.controller,
    this.validator,
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8,
    this.name = "Password",
    this.forceErrMsg,
    this.onChanged,
  }) : inputType = AvertInputType.password, required = true ;

  final String name;
  final double xPadding, yPadding;
  final double gapPadding;
  final AvertInputType inputType;
  final TextEditingController controller;
  final bool required;
  final String? Function(String? value)? validator;
  final String? forceErrMsg;
  final void Function(String? value)? onChanged;
  
  @override
  State<StatefulWidget> createState() => _InputState();
}

class _InputState extends State<AvertInput> {

  bool shouldObscure = true;

  @override
  Widget build(BuildContext context) {
    switch(widget.inputType) {
      case AvertInputType.alphanumeric:
        return alphanumeric(context);
      case AvertInputType.password:
        return password(context);
      default:
        return text(context);
    }
  }

  Widget alphanumeric(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: widget.xPadding, vertical: widget.yPadding),
    child: TextFormField(
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z_]")),
      ],
      validator: validate,
      controller: widget.controller,
      forceErrorText: widget.forceErrMsg,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        iconColor: Colors.white,
        border: OutlineInputBorder(
          gapPadding: widget.gapPadding,
        ),
        labelText: widget.name,
        //errorText: errMsg,
      )
    )
  
  );

  Widget text(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: widget.xPadding, vertical: widget.yPadding),
    child: TextFormField(
      validator: validate,
      controller: widget.controller,
      forceErrorText: widget.forceErrMsg,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        iconColor: Colors.white,
        border: OutlineInputBorder(
          gapPadding: widget.gapPadding,
        ),
        labelText: widget.name,
        //errorText: errMsg,
      )
    )
  );

  Widget password(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: widget.xPadding, vertical: widget.yPadding),
    child: TextFormField(
      validator: validate,
      obscureText: shouldObscure,
      forceErrorText: widget.forceErrMsg,
      onChanged: widget.onChanged,
      enableSuggestions: false,
      autocorrect: false,
      controller: widget.controller,
      decoration: InputDecoration(
        suffixIcon: showButton(context),
        iconColor: Colors.white,
        border: OutlineInputBorder(
          gapPadding: widget.gapPadding,
        ),
        labelText: widget.name,
        //errorText: errMsg,
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

  String? validate(String? value) {
    printDebug("validating value: $value");
    if (widget.required && (value == null || value.isEmpty)) {
      printDebug("Required non empty field of ${widget.name}");
      return "${widget.name} is required!";
    }
    return widget.validator == null ? null : widget.validator!(value);
  }
}
