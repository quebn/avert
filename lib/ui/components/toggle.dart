import "package:avert/utils/logger.dart";
import "package:flutter/material.dart";
import "package:forui/forui.dart";

class AvertToggle extends StatelessWidget {
  const AvertToggle({super.key,
    required this.initialValue,
    required this.label,
    this.description,
    this.onChange,
  });

  final String label;
  final bool initialValue;
  final Widget? description;
  final void Function(bool)? onChange;

  @override
  Widget build(BuildContext context) {
    FThemeData theme = FTheme.of(context);
    FLabelStateStyles textStyle = theme.textFieldStyle.labelStyle.state;
    return FLabel(
      axis: Axis.vertical,
      label: Text(label,
        style: textStyle.enabledStyle.labelTextStyle.copyWith(fontWeight: FontWeight.normal),
      ),
      description: description,
      child: FormField<bool>(
        initialValue: initialValue,
        builder: _builder,
      ),
    );
  }

  Widget _builder(FormFieldState<bool> state) {
    printAssert(state.value != null, "State value null");
    return FSwitch(
      value: state.value!,
      onChange: (value) {
        state.didChange(value);
        onChange?.call(value);
      },
    );
  }
}
