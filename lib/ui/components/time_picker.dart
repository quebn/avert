import "package:avert/utils/logger.dart";
import "package:flutter/material.dart";
import "package:forui/forui.dart";

class AvertTimePicker extends StatefulWidget {
  const AvertTimePicker({super.key,
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
    this.labelStyle,
    this.forceErrorText,
    this.yMargin = 4,
    this.onChange,
  });

  final String label;
  final Widget? prefix, suffix, description, error;
  final bool enabled, required;
  final Function()? validator;
  final int flex;
  final String? forceErrorText;
  final FTimeFieldController controller;
  final TextStyle? labelStyle;
  final double yMargin;
  final void Function(FTime? time)? onChange;

  @override
  State<StatefulWidget> createState() => _SelectState();
}

class _SelectState extends State<AvertTimePicker> {

  @override
  void initState() {
    super.initState();
    if (widget.onChange != null) {
      widget.controller.addValueListener(widget.onChange!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.onChange != null) {
      widget.controller.removeValueListener(widget.onChange!);
    }
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

    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.yMargin),
      child: FTimeField.picker(
        key: widget.key,
        controller: widget.controller,
        label: label,
        description: widget.description,
        enabled: widget.enabled,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        forceErrorText: widget.forceErrorText,
      ),
    );
  }
}
