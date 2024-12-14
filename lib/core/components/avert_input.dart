import "package:flutter/material.dart";
import "package:avert/core/utils/common.dart";
import "package:flutter/services.dart";
import "package:forui/forui.dart";
import "package:forui_assets/forui_assets.dart";

enum AvertInputType {
  text,
  alphanumeric,
  password,
}

class AvertInput extends StatefulWidget {
  const AvertInput({super.key,
    required this.label,
    required this.controller,
    required this.inputType,
    this.xMargin = 0,
    this.yMargin = 0,
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
  });

  const AvertInput.text({super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.required = false,
    this.validator,
    this.onChange,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.xMargin = 0,
    this.yMargin = 0,
    this.labelStyle,
    this.initialValue,
    this.textInputAction,
    this.description,
    this.autovalidateMode,
    this.forceErrMsg,
  }): inputType = AvertInputType.text;

  const AvertInput.alphanumeric({super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.xMargin = 0,
    this.yMargin = 0,
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
  }) : inputType = AvertInputType.alphanumeric;

  const AvertInput.password({super.key,
    required this.controller,
    this.hint,
    this.validator,
    this.label = "Password",
    this.xMargin = 0,
    this.yMargin = 0,
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
  }) : inputType = AvertInputType.password, required = true;

  final String label;
  final String? hint, initialValue, forceErrMsg;
  final double xMargin, yMargin;
  final AvertInputType inputType;
  final TextEditingController controller;
  final bool required, readOnly, autofocus, enabled;
  final String? Function(String? value)? validator;
  final void Function(String? value)? onChange;
  final TextStyle? labelStyle;
  final Widget? description;
  final TextInputAction? textInputAction;
  final AutovalidateMode? autovalidateMode;

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
      case AvertInputType.alphanumeric:
        textFormField = _alphanumericField;
        break;
      case AvertInputType.password:
        textFormField = _passwordField;
        break;
      default:
        textFormField = _textField;
        break;
    }
    Widget content =  Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.xMargin, vertical: widget.yMargin),
      child: textFormField,
    );
    return content;
  }

  // TODO: turn this into richtext.
  Widget get _label => RichText(
    text: TextSpan(
      text:widget.label,
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

  Widget get _textField => FTextField(
    description: widget.description,
    textInputAction: widget.textInputAction ?? TextInputAction.done,
    label: Text(widget.label, style: widget.labelStyle), // TODO: turn this into richtext.
    hint: widget.hint,
    autofocus: widget.autofocus,
    readOnly: widget.readOnly,
    validator: _validate,
    controller: widget.controller,
    onChange: widget.onChange,
    enabled: widget.enabled,
    maxLines: 1,
    autovalidateMode: widget.autovalidateMode,
    keyboardType: TextInputType.text,
    forceErrorText: widget.forceErrMsg,
  );

  Widget get _alphanumericField => FTextField(
    label: _label,
    description: widget.description,
    readOnly: widget.readOnly,
    textInputAction: widget.textInputAction ?? TextInputAction.done,
    hint: widget.hint,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z_]")),
    ],
    autovalidateMode: widget.autovalidateMode,
    autofocus: widget.autofocus,
    validator: _validate,
    controller: widget.controller,
    onChange: widget.onChange,
    enabled: widget.enabled,
    keyboardType: TextInputType.text,
    maxLines: 1,
    forceErrorText: widget.forceErrMsg,
  );

  Widget get _passwordField => FTextField.password(
    label: _label,
    readOnly: widget.readOnly,
    obscureText: shouldObscure,
    validator: _validate,
    onChange: widget.onChange,
    controller: widget.controller,
    enabled: widget.enabled,
    forceErrorText: widget.forceErrMsg,
    autovalidateMode: widget.autovalidateMode,
    keyboardType: TextInputType.visiblePassword,
    suffix: _showButton(),
  );

  Widget _showButton() => IconButton(
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

  String? _validate(String? value) {
    if (widget.required && (value == null || value.isEmpty)) {
      return "${widget.label} is required!";
    }
    return widget.validator == null ? null : widget.validator!(value);
  }
}
