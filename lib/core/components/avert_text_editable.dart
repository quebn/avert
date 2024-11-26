import "package:flutter/material.dart";
import "package:avert/core/utils/logger.dart";

class AvertTextEditable extends StatefulWidget {
  const AvertTextEditable({
    super.key,
    required this.name,
    required this.controller,
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8,
    this.required = false,
    this.validator,
    this.fontSize,
    this.forceErrMsg,
    this.onChanged,
  });

  final String name;
  final double xPadding, yPadding;
  final double gapPadding;
  final double? fontSize;
  final TextEditingController controller;
  final bool required;
  final String? Function(String? value)? validator;
  final String? forceErrMsg;
  final void Function(String? value)? onChanged;

  @override
  State<StatefulWidget> createState() => _TextEditableState();
}

class _TextEditableState extends State<AvertTextEditable> {
  bool editing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: widget.xPadding, vertical: widget.yPadding),
      child: TextFormField(
        readOnly: !editing,
        style: TextStyle(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
        validator: validate,
        controller: widget.controller,
        forceErrorText: widget.forceErrMsg,
        onChanged: widget.onChanged,
        expands: false,
        decoration: InputDecoration(
          suffix: editing ? null : IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit_outlined),
          ),
          border: InputBorder.none,
        ),
      )
    );
  }

  String? validate(String? value) {
    printDebug("validating value: $value");
    if (widget.required && (value == null || value.isEmpty)) {
      printDebug("Required non empty field of ${widget.name}");
      return "${widget.name} is required!";
    }
    return widget.validator == null ? null : widget.validator!(value);
  }
}
