import "package:avert/utils/logger.dart";
import "package:flutter/material.dart";
import "package:forui/forui.dart";

class AvertDatePicker extends StatefulWidget {
  const AvertDatePicker({super.key,
    required this.label,
    required this.controller,
    this.description,
    this.error,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.validator,
    this.required = false,
    this.labelStyle,
    this.forceErrorText,
  });

  final String label;
  final Widget? prefix, suffix, description, error;
  final bool enabled, required;
  final Function()? validator;
  final TextStyle? labelStyle;
  final String? forceErrorText;
  final FDateFieldController controller;

  @override
  State<StatefulWidget> createState() => _SelectState();
}

class _SelectState extends State<AvertDatePicker> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building Date Picker ${widget.label}");
    final Widget label = RichText(
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

    return FDateField.calendar(
      key: widget.key,
      controller: widget.controller,
      autoHide: true,
      clearable: true,
      label: label,
      description: widget.description,
      enabled: widget.enabled,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      forceErrorText: widget.forceErrorText,
    );
  }
}
