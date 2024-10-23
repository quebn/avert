import "package:flutter/material.dart";
import "package:acqua/core/utils.dart";
import "package:flutter/services.dart";

enum AcquaInputType {
  text,
  alphanumeric,
  password,
  datetime,
}

class AcquaInput extends StatefulWidget {
  const AcquaInput({
    super.key,
    required this.name,
    required this.controller,
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8,
    this.inputType = AcquaInputType.text,
    this.required = false,
    this.validator,
  });

  const AcquaInput.alphanumeric({
    super.key, 
    required this.name, 
    required this.controller,
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8, 
    this.required = false,
    this.validator,
  }) : inputType = AcquaInputType.alphanumeric;

  const AcquaInput.password({
    super.key, 
    required this.controller,
    this.validator,
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8, 
    this.name = "Password", 
  }) : inputType = AcquaInputType.password, required = true ;

  final String name;
  final double xPadding, yPadding;
  final double gapPadding;
  final AcquaInputType inputType;
  final TextEditingController controller;
  final bool required;
  final String? Function(String? value)? validator;
  
  @override
  State<StatefulWidget> createState() => _InputState();
}

class _InputState extends State<AcquaInput> {

  bool shouldObscure = true;

  @override
  Widget build(BuildContext context) {
    switch(widget.inputType) {
      case AcquaInputType.alphanumeric:
        return alphanumeric(context);
      case AcquaInputType.password:
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
    printLog("validating value: $value");
    if (widget.required && (value == null || value.isEmpty)) {
      printLog("Required non empty field of ${widget.name}");
      return "${widget.name} is required!";
    }
    return widget.validator == null ? null : widget.validator!(value);
  }
}
