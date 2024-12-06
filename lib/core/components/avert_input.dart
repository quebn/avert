import "package:flutter/material.dart";
import "package:avert/core/utils/logger.dart";
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
    required this.label,
    required this.controller,
    this.placeHolder = "Text",
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8,
    this.inputType = AvertInputType.text,
    this.required = false,
    this.validator,
    this.forceErrMsg,
    this.onChanged,
    this.readOnly = false,
    this.autofocus = false,
    this.decoration,
    this.labelStyle,
  });

  const AvertInput.alphanumeric({
    super.key,
    required this.label,
    required this.controller,
    this.placeHolder = "Text",
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8,
    this.required = false,
    this.validator,
    this.forceErrMsg,
    this.onChanged,
    this.readOnly = false,
    this.autofocus = false,
    this.decoration,
    this.labelStyle,
  }) : inputType = AvertInputType.alphanumeric;

  const AvertInput.password({
    super.key,
    required this.controller,
    this.placeHolder = "********",
    this.validator,
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8,
    this.label = "Password",
    this.forceErrMsg,
    this.onChanged,
    this.readOnly = false,
    this.autofocus = false,
    this.decoration,
    this.labelStyle,
  }) : inputType = AvertInputType.password, required = true ;

  final String label, placeHolder;
  final double xPadding, yPadding;
  final double gapPadding;
  final AvertInputType inputType;
  final TextEditingController controller;
  final bool required, readOnly, autofocus;
  final String? Function(String? value)? validator;
  final String? forceErrMsg;
  final void Function(String? value)? onChanged;
  final InputDecoration? decoration;
  final TextStyle? labelStyle;

  @override
  State<StatefulWidget> createState() => _InputState();
}

class _InputState extends State<AvertInput> {

  bool shouldObscure = true;

  @override
  Widget build(BuildContext context) {
    Widget textFormField;
    switch(widget.inputType) {
      case AvertInputType.alphanumeric:
        textFormField =  alphanumeric(context);
      case AvertInputType.password:
        textFormField =  password(context);
      default:
        textFormField =  text(context);
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.xPadding, vertical: widget.yPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.label,
            style: widget.labelStyle ?? TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          textFormField,
        ],
      )
    );
  }

  InputDecoration get defaultDecoration => InputDecoration(
    floatingLabelBehavior: FloatingLabelBehavior.never,
    iconColor: Colors.white,
    border: OutlineInputBorder(
      gapPadding: widget.gapPadding,
    ),
    labelText: widget.placeHolder,
    //errorText: errMsg,
  );

  Widget alphanumeric(BuildContext context) => TextFormField(
    readOnly: widget.readOnly,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z_]")),
    ],
    autofocus: widget.autofocus,
    validator: validate,
    controller: widget.controller,
    forceErrorText: widget.forceErrMsg,
    onChanged: widget.onChanged,
    decoration: widget.decoration ?? defaultDecoration,
  );

  Widget text(BuildContext context) => TextFormField(
    readOnly: widget.readOnly,
    validator: validate,
    controller: widget.controller,
    forceErrorText: widget.forceErrMsg,
    onChanged: widget.onChanged,
    decoration: widget.decoration ?? defaultDecoration,
  );

  Widget password(BuildContext context) => TextFormField(
    readOnly: widget.readOnly,
    validator: validate,
    obscureText: shouldObscure,
    forceErrorText: widget.forceErrMsg,
    onChanged: widget.onChanged,
    enableSuggestions: false,
    autocorrect: false,
    controller: widget.controller,
    decoration: widget.decoration ?? defaultDecoration,
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
    printInfo("validating value: $value");
    if (widget.required && (value == null || value.isEmpty)) {
      printInfo("Required non empty field of ${widget.label}");
      return "${widget.label} is required!";
    }
    return widget.validator == null ? null : widget.validator!(value);
  }
}
