import "package:flutter/material.dart";
import "package:avert/core/utils/logger.dart";
import "package:avert/core/utils/common.dart";
import "package:flutter/services.dart";

enum AvertInputType {
  text,
  numeric,
  alphanumeric,
  password,
  date,
}

class AvertInput extends StatefulWidget {
  const AvertInput({super.key,
    required this.label,
    required this.controller,
    required this.inputType,
    this.placeholder = "Enter Text",
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8,
    this.required = false,
    this.validator,
    this.forceErrMsg,
    this.onChanged,
    this.readOnly = false,
    this.autofocus = false,
    this.expand = false,
    this.enabled = true,
    this.decoration,
    this.labelStyle,
    this.listener,
    this.initialValue,
  });

  const AvertInput.text({super.key,
    required this.label,
    required this.controller,
    required this.placeholder,
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8,
    this.required = false,
    this.validator,
    this.forceErrMsg,
    this.onChanged,
    this.readOnly = false,
    this.autofocus = false,
    this.expand = false,
    this.enabled = true,
    this.decoration,
    this.labelStyle,
    this.listener,
    this.initialValue,
  }): inputType = AvertInputType.text;

  const AvertInput.alphanumeric({super.key,
    required this.label,
    required this.controller,
    this.placeholder = "Text",
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8,
    this.required = false,
    this.validator,
    this.forceErrMsg,
    this.onChanged,
    this.readOnly = false,
    this.autofocus = false,
    this.expand = false,
    this.enabled = true,
    this.decoration,
    this.labelStyle,
    this.listener,
    this.initialValue,
  }) : inputType = AvertInputType.alphanumeric;

  const AvertInput.password({super.key,
    required this.controller,
    this.placeholder = "",
    this.validator,
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8,
    this.label = "Password",
    this.forceErrMsg,
    this.onChanged,
    this.readOnly = false,
    this.autofocus = false,
    this.expand = false,
    this.enabled = true,
    this.decoration,
    this.labelStyle,
    this.listener,
    this.initialValue,
  }) : inputType = AvertInputType.password, required = true ;

  const AvertInput.date({super.key,
    required this.label,
    required this.controller,
    this.placeholder = "YYYY-MM-DD",
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8,
    this.required = false,
    this.expand = false,
    this.enabled = true,
    this.validator,
    this.forceErrMsg,
    this.onChanged,
    this.decoration,
    this.labelStyle,
    this.listener,
    this.initialValue,
  }) : inputType = AvertInputType.date, readOnly = true, autofocus = false;

  const AvertInput.numeric({super.key,
    required this.controller,
    this.placeholder = "0",
    this.validator,
    this.xPadding = 8,
    this.yPadding = 8,
    this.gapPadding = 8,
    this.label = "Enter Number",
    this.forceErrMsg,
    this.onChanged,
    this.required = false,
    this.readOnly = false,
    this.autofocus = false,
    this.expand = false,
    this.enabled = true,
    this.decoration,
    this.labelStyle,
    this.listener,
    this.initialValue,
  }) : inputType = AvertInputType.numeric;

  final String label, placeholder;
  final double xPadding, yPadding;
  final double gapPadding;
  final AvertInputType inputType;
  final TextEditingController controller;
  final bool required, readOnly, autofocus, expand, enabled;
  final String? Function(String? value)? validator;
  final String? forceErrMsg, initialValue;
  final void Function(String? value)? onChanged;
  final InputDecoration? decoration;
  final TextStyle? labelStyle;
  final void Function()? listener;

  @override
  State<StatefulWidget> createState() => _InputState();
}

class _InputState extends State<AvertInput> {

  bool shouldObscure = true;

  @override
  void initState() {
    super.initState();
    if (widget.listener != null) {
      widget.controller.addListener(widget.listener!);
    }
    if (widget.initialValue != null) {
      widget.controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.listener != null) {
      widget.controller.removeListener(widget.listener!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget textFormField;
    switch(widget.inputType) {
      case AvertInputType.alphanumeric:
        textFormField = alphanumericField(context);
      case AvertInputType.date:
        textFormField = dateField(context);
      case AvertInputType.numeric:
        textFormField = numericField(context);
      case AvertInputType.password:
        textFormField = passwordField(context);
      default:
        textFormField = textField(context);
    }
    Widget content =  Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.xPadding, vertical: widget.yPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TODO: make this into a richtext that show
          // on the label whether this field is required.
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
    if (widget.expand) return Expanded(child: content);
    return content;
  }

  InputDecoration get defaultDecoration => InputDecoration(
    border: OutlineInputBorder(
      gapPadding: widget.gapPadding,
    ),
    hintText: widget.placeholder,
    //errorText: errMsg,
  );

  Widget dateField(BuildContext context) => TextFormField(
    readOnly: true,
    keyboardType: TextInputType.datetime,
    enableSuggestions: false,
    autocorrect: false,
    autofocus: widget.autofocus,
    validator: validate,
    controller: widget.controller,
    forceErrorText: widget.forceErrMsg,
    onChanged: widget.onChanged,
    decoration: widget.decoration ?? InputDecoration(
      iconColor: Colors.white,
      border: OutlineInputBorder(
        gapPadding: widget.gapPadding,
      ),
      hintText: widget.placeholder,
      suffixIcon: datepicker(),
    ),
    enabled: widget.enabled,
  );

  Widget numericField(BuildContext context) => TextFormField(
    readOnly: widget.readOnly,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp("[0-9]")),
    ],
    enableSuggestions: false,
    autocorrect: false,
    keyboardType: TextInputType.number,
    autofocus: widget.autofocus,
    validator: validate,
    controller: widget.controller,
    forceErrorText: widget.forceErrMsg,
    onChanged: widget.onChanged,
    decoration: widget.decoration ?? defaultDecoration,
    enabled: widget.enabled,
  );

  Widget alphanumericField(BuildContext context) => TextFormField(
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
    enabled: widget.enabled,
  );

  Widget textField(BuildContext context) => TextFormField(
    readOnly: widget.readOnly,
    validator: validate,
    controller: widget.controller,
    forceErrorText: widget.forceErrMsg,
    onChanged: widget.onChanged,
    decoration: widget.decoration ?? defaultDecoration,
    enabled: widget.enabled,
  );

  Widget passwordField(BuildContext context) => TextFormField(
    readOnly: widget.readOnly,
    validator: validate,
    obscureText: shouldObscure,
    forceErrorText: widget.forceErrMsg,
    onChanged: widget.onChanged,
    enableSuggestions: false,
    autocorrect: false,
    controller: widget.controller,
    decoration: widget.decoration ?? InputDecoration(
      suffixIcon: showButton(),
      iconColor: Colors.white,
      border: OutlineInputBorder(
        gapPadding: widget.gapPadding,
      ),
      hintText: widget.placeholder,
      //errorText: errMsg,
    ),
    enabled: widget.enabled,
  );

  Widget datepicker() => IconButton(
    iconSize: 28,
    icon: const Icon(Icons.calendar_month),
    onPressed: () async {
      DateTime? dt = await showDatePicker(
        context: context,
        initialDate: DateTime.parse(widget.controller.text),
        firstDate: DateTime(2024),
        lastDate: DateTime(2025),
      );
      if (dt == null) return;
      setState(() => widget.controller.text = getDate(dt));
    },
  );

  Widget showButton() => IconButton(
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

Widget foo() {
  return InputDatePickerFormField(
    firstDate: DateTime(2024),
    lastDate: DateTime(2025),
  );
}
