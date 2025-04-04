import "package:avert/utils/logger.dart";
import "package:flutter/material.dart";
import "package:forui/forui.dart";

class AvertDTPicker extends StatefulWidget {
  const AvertDTPicker({super.key,
    required this.label,
    required this.controller,
    this.description,
    this.error,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.validator,
    this.flex = 0,
    this.required = false,
    this.forceErrorText,
  });

  final String label;
  final Widget? prefix, suffix, description, error;
  final bool enabled, required;
  final Function()? validator;
  final int flex;
  final String? forceErrorText;
  final FDateFieldController controller;

  @override
  State<StatefulWidget> createState() => _SelectState();
}

class _SelectState extends State<AvertDTPicker> {

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
    return FDateField.calendar(
      key: widget.key,
      controller: widget.controller,
      autoHide: true,
      clearable: true,
      label: Text(widget.label),
      description: widget.description,
      enabled: widget.enabled,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      forceErrorText: widget.forceErrorText,
    );
  }
}
