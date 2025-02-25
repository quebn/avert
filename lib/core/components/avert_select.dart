import "package:avert/core/core.dart";
import "package:avert/core/utils/ui.dart";
import "package:forui/forui.dart";

class AvertSelect<T extends Object> extends StatelessWidget {
  const AvertSelect({super.key,
    required this.label,
    required this.valueBuilder,
    required this.tileSelectBuilder,
    required this.options,
    this.initialValue,
    this.description,
    this.error,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.dialogActions = const [],
    this.flex = 0,
    this.required = false,
    this.validator,
    this.onSaved,
    this.forceErrorText,
  }): optionsQuery = null;

  const AvertSelect.queryOptions({super.key,
    required this.label,
    required this.valueBuilder,
    required this.tileSelectBuilder,
    required this.optionsQuery,
    this.initialValue,
    this.description,
    this.error,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.dialogActions = const [],
    this.flex = 0,
    this.required = false,
    this.validator,
    this.onSaved,
    this.forceErrorText,
  }): options = const [];

  final String label;
  final Widget Function(BuildContext, T?) valueBuilder;
  final Widget Function(BuildContext, T) tileSelectBuilder;
  final T? initialValue;
  final List<T> options;
  final Widget? prefix, suffix, description, error;
  final bool enabled, required;
  final List<Widget> dialogActions;
  final int flex;
  final Future<List<T>> Function()? optionsQuery;
  final void Function(T?)? onSaved;
  final String? Function(T?)? validator;
  final String? forceErrorText;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      key: key,
      onSaved: onSaved,
      enabled: enabled,
      builder: (state) => _builder(context, state),
      validator: _validate,
      initialValue: initialValue,
      forceErrorText: forceErrorText,
    );
  }

  Widget _builder(BuildContext context, FormFieldState<T> state) {
    final FThemeData theme = FTheme.of(context);
    final FButtonCustomStyle style = theme.buttonStyles.outline;
    final FButtonCustomStyle errstyle = theme.buttonStyles.outline.copyWith(
      contentStyle: theme.buttonStyles.outline.contentStyle.copyWith(
        enabledIconColor: theme.colorScheme.destructive,
      ),
      enabledBoxDecoration: theme.buttonStyles.outline.enabledBoxDecoration.copyWith(
        border: Border.all(color:theme.colorScheme.destructive),
      )
    );

    final TextStyle enabledTextStyle = theme.textFieldStyle.enabledStyle.labelTextStyle;
    final TextStyle errorTextStyle = theme.textFieldStyle.errorStyle.labelTextStyle;
    return Flexible(
      flex: flex,
      child: FLabel(
        error: state.hasError ? Text(state.errorText!) : null,
        axis: Axis.vertical,
        label: RichText(
          text: TextSpan(
            style: state.hasError ? errorTextStyle : enabledTextStyle,
            text: label,
            children:  required ? const [
              TextSpan(
                text: " *",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                )
              ),
            ] : null,
          ),
        ),
        description: description,
        child: FButton(
          style: state.hasError ? errstyle : style,
          onPress: options.isNotEmpty ? () async => _select(context, state) : null,
          suffix: suffix,
          prefix: prefix,
          label: Expanded(
            child: valueBuilder(context, state.value),
          )
        ),
      ),
    );
  }

  String? _validate(T? value) {
    if (required && value == null) {
      return "$label is required!";
    }
    return validator == null ? null : validator!(value);
  }

  Future<void> _select(BuildContext context, FormFieldState<T> state) async {
    List<T> choices = options;
    if (optionsQuery != null) {
      choices = await optionsQuery!();
      if (!context.mounted) return;
    }
    if (choices.isEmpty) {
      notify(context, "$label: No available selections!");
      return;
    }
    T? value = await _openSelectionDialog(context, choices);
    if (value == null) return;
    state.didChange(value);
  }

  Future<T?> _openSelectionDialog(BuildContext context, List<T> selections) {
    final FThemeData theme = FTheme.of(context);
    return showAdaptiveDialog<T>(
      context: context,
      builder: (BuildContext context) => FDialog.raw(
        builder: (context, style) => FCard.raw(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Card(
              color: theme.colorScheme.background,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select $label",
                    style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: selections.length,
                    itemBuilder: (context, index) {
                      return tileSelectBuilder(context, selections[index]);
                    },
                  ),
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}
