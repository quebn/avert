import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:forui/forui.dart";

enum AvertInputType {
  text,
  number,
  alphanumeric,
  password,
  multiline,
}

class AvertInput extends StatefulWidget {
  const AvertInput({super.key,
    required this.label,
    required this.controller,
    required this.inputType,
    this.xMargin = 0,
    this.yMargin = 4,
    this.onTap,
    this.hint,
    this.required = false,
    this.validator,
    this.onChange,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.labelStyle,
    this.initialValue,
    this.textInputAction,
    this.description,
    this.autovalidateMode,
    this.forceErrMsg,
    this.minLines = 1,
    this.maxLines = 1,
  }): isDecimal = false;

  const AvertInput.text({super.key,
    required this.label,
    required this.controller,
    this.onTap,
    this.hint,
    this.required = false,
    this.validator,
    this.onChange,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.xMargin = 0,
    this.yMargin = 4,
    this.labelStyle,
    this.initialValue,
    this.textInputAction,
    this.description,
    this.autovalidateMode,
    this.forceErrMsg,
    this.minLines = 1,
    this.maxLines = 1,
  }): inputType = AvertInputType.text, isDecimal = false;

  const AvertInput.number({super.key,
    required this.label,
    required this.controller,
    this.onTap,
    this.isDecimal = false,
    this.hint,
    this.required = false,
    this.validator,
    this.onChange,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.xMargin = 0,
    this.yMargin = 4,
    this.labelStyle,
    this.initialValue,
    this.textInputAction,
    this.description,
    this.autovalidateMode,
    this.forceErrMsg,
    this.minLines = 1,
    this.maxLines = 1,
  }): inputType = AvertInputType.number;

  const AvertInput.alphanumeric({super.key,
    required this.label,
    required this.controller,
    this.onTap,
    this.hint,
    this.xMargin = 0,
    this.yMargin = 4,
    this.required = false,
    this.validator,
    this.onChange,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.labelStyle,
    this.initialValue,
    this.textInputAction,
    this.description,
    this.autovalidateMode,
    this.forceErrMsg,
    this.minLines = 1,
    this.maxLines = 1,
  }) : inputType = AvertInputType.alphanumeric, isDecimal = false;

  const AvertInput.password({super.key,
    required this.controller,
    this.onTap,
    this.hint,
    this.validator,
    this.label = "Password",
    this.xMargin = 0,
    this.yMargin = 4,
    this.onChange,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.labelStyle,
    this.initialValue,
    this.textInputAction,
    this.description,
    this.autovalidateMode,
    this.forceErrMsg,
  }) : inputType = AvertInputType.password, required = true, minLines = 1, maxLines = 1, isDecimal = false;

  const AvertInput.multiline({
    super.key,
    required this.label,
    required this.controller,
    this.onTap,
    this.hint,
    this.required = false,
    this.validator,
    this.onChange,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.xMargin = 0,
    this.yMargin = 4,
    this.labelStyle,
    this.initialValue,
    this.textInputAction,
    this.description,
    this.autovalidateMode,
    this.forceErrMsg,
    this.minLines = 3,
    this.maxLines = 3,
  }): inputType = AvertInputType.multiline, isDecimal = false;

  final String label;
  final String? hint, initialValue, forceErrMsg;
  final double xMargin, yMargin;
  final AvertInputType inputType;
  final TextEditingController controller;
  final bool required, readOnly, autofocus, enabled;
  final String? Function(String? value)? validator;
  final void Function(String? value)? onChange;
  final void Function()? onTap;
  final TextStyle? labelStyle;
  final Widget? description;
  final TextInputAction? textInputAction;
  final AutovalidateMode? autovalidateMode;
  final int? minLines, maxLines;
  final bool isDecimal;

  @override
  State<StatefulWidget> createState() => _InputState();
}

class _InputState extends State<AvertInput> {

  bool shouldObscure = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      widget.controller.text = widget.initialValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget textFormField;
    switch(widget.inputType) {
      case AvertInputType.number: {
        textFormField = numberField;
      } break;
      case AvertInputType.alphanumeric: {
        textFormField = alphanumericField;
      } break;
      case AvertInputType.password: {
        textFormField = passwordField;
      } break;
      case AvertInputType.multiline: {
        textFormField = multilineField;
      } break;
      default: {
        textFormField = textField;
      } break;
    }
    Widget content =  Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.xMargin, vertical: widget.yMargin),
      child: textFormField,
    );
    return content;
  }

  Widget get label => RichText(
    text: TextSpan(
      text: widget.label,
      style: widget.labelStyle,
      children:  widget.required ? const [
        TextSpan(
          text: " *",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          )
        ),
      ] : null,
    ),
  );

  Widget get textField => FTextField(
    minLines: widget.minLines,
    description: widget.description,
    textInputAction: widget.textInputAction ?? TextInputAction.done,
    label: label,
    hint: widget.hint,
    autofocus: widget.autofocus,
    readOnly: widget.readOnly,
    validator: validate,
    controller: widget.controller,
    onChange: widget.onChange,
    enabled: widget.enabled,
    maxLines: 1,
    autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
    keyboardType: TextInputType.text,
    forceErrorText: widget.forceErrMsg,
    onTap: widget.onTap,
  );

  Widget get numberField => FTextField(
    minLines: widget.minLines,
    label: label,
    description: widget.description,
    readOnly: widget.readOnly,
    textInputAction: widget.textInputAction ?? TextInputAction.done,
    hint: widget.hint,
    autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
    autofocus: widget.autofocus,
    validator: validate,
    controller: widget.controller,
    onChange: widget.onChange,
    enabled: widget.enabled,
    keyboardType: TextInputType.numberWithOptions(
      signed: false, decimal: widget.isDecimal
    ),
    maxLines: 1,
    forceErrorText: widget.forceErrMsg,
    onTap: widget.onTap,
  );

  Widget get alphanumericField => FTextField(
    minLines: widget.minLines,
    label: label,
    description: widget.description,
    readOnly: widget.readOnly,
    textInputAction: widget.textInputAction ?? TextInputAction.done,
    hint: widget.hint,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z_]")),
    ],
    autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
    autofocus: widget.autofocus,
    validator: validate,
    controller: widget.controller,
    onChange: widget.onChange,
    enabled: widget.enabled,
    keyboardType: TextInputType.text,
    maxLines: 1,
    forceErrorText: widget.forceErrMsg,
    onTap: widget.onTap,
  );

  Widget get passwordField => FTextField.password(
    minLines: widget.minLines,
    label: label,
    readOnly: widget.readOnly,
    obscureText: shouldObscure,
    validator: validate,
    onChange: widget.onChange,
    controller: widget.controller,
    enabled: widget.enabled,
    forceErrorText: widget.forceErrMsg,
    autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
    keyboardType: TextInputType.visiblePassword,
    suffixBuilder: (context, state, widget) => showButton(),
    onTap: widget.onTap,
  );

  Widget get multilineField => FTextField.multiline(
    minLines: widget.minLines,
    maxLines: widget.maxLines,
    description: widget.description,
    label: label,
    hint: widget.hint,
    autofocus: widget.autofocus,
    readOnly: widget.readOnly,
    validator: validate,
    controller: widget.controller,
    onChange: widget.onChange,
    enabled: widget.enabled,
    autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
    forceErrorText: widget.forceErrMsg,
    onTap: widget.onTap,
  );


  Widget showButton() => IconButton(
    //padding: EdgeInsets.all(0),
    iconSize: 28,
    isSelected: shouldObscure,
    icon: FIcon(FAssets.icons.eyeClosed),
    selectedIcon: FIcon(FAssets.icons.eye),
    onPressed: () {
      setState(() {
        shouldObscure = !shouldObscure;
      });
    },
  );

  String? validate(String? value) {
    if (widget.required && (value == null || value.isEmpty)) {
      return "${widget.label} is required!";
    }
    return widget.validator?.call(value);
  }
}
