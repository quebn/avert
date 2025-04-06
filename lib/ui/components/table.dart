import "package:avert/docs/core.dart";
import "package:flutter/material.dart";
import "package:forui/forui.dart";

class AvertTable<T extends Document> extends StatelessWidget {
  const AvertTable({super.key,
    required this.label,
    this.header,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.onSaved,
    this.description,
    this.error,
    this.forceErrorText,
    this.restorationId,
    this.initialValue,
    this.autovalidateMode,
  });

  final String label;
  final void Function(T?)? onSaved;
  final String? forceErrorText, restorationId;
  final String? Function(T?)? validator;
  final T? initialValue;
  final bool enabled, required;
  final AutovalidateMode? autovalidateMode;
  final Widget? description, error;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = FTheme.of(context);
    final TextStyle enabledTextStyle = theme.textFieldStyle.enabledStyle.labelTextStyle;
    final TextStyle errorTextStyle = theme.textFieldStyle.errorStyle.labelTextStyle;

    return FormField<T>(
      builder: (state) {
        return SizedBox(
          child: FLabel(
            error: state.hasError ? Text(state.errorText!) : null,
            axis: Axis.vertical,
            label: _label(state.hasError, errorTextStyle, enabledTextStyle),
            description: description,
            child: _table(context, state),
          ),
        );
      }
    );
  }

  Widget _label(bool hasError, TextStyle destruction, TextStyle enabled) {
    return RichText(
      text: TextSpan(
        style: hasError ? destruction : enabled,
        text: label,
        children:  required ? [
          TextSpan(
            text: " *",
            style: destruction
          ),
        ] : null,
      ),
    );
  }

  Widget _table(BuildContext context, FormFieldState<T> state) {
    return FCard.raw(
      child: Column(
        children: [],
      ),
    );
  }
}

// AvertTableRow();
