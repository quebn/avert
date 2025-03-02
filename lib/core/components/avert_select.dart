import "package:avert/core/core.dart";
import "package:avert/core/utils/ui.dart";
import "package:forui/forui.dart";

// TODO: use StatefulWidget in the future and use controller listeners to update the state.
class AvertSelect<T extends Object> extends StatelessWidget {
  const AvertSelect({super.key,
    required this.label,
    required this.valueBuilder,
    required this.tileSelectBuilder,
    required this.options,
    required this.controller,
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
  });

  final String label;
  final Widget Function(BuildContext, T?) valueBuilder;
  final AvertSelectTile Function(BuildContext, T) tileSelectBuilder;
  final T? initialValue;
  final List<T> options;
  final Widget? prefix, suffix, description, error;
  final bool enabled, required;
  final List<Widget> dialogActions;
  final int flex;
  final void Function(T?)? onSaved;
  final String? Function(T?)? validator;
  final String? forceErrorText;
  final FRadioSelectGroupController<T> controller;

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
    if (options.isEmpty) {
      notify(context, "$label: No available selections!");
      return;
    }
    T? value = await _openSelectionDialog(context, options);
    if (value == null) return;
    controller.update(value, selected: true);
    state.didChange(value);
  }

  Future<T?> _openSelectionDialog(BuildContext context, List<T> selections) {
    final FThemeData theme = FTheme.of(context);
    FDialogStyle dialogStyle = theme.dialogStyle.copyWith(
      decoration: theme.dialogStyle.decoration.copyWith(
        border: Border.all(color: theme.colorScheme.border, width: 2)
      ),
    );

    final List<Widget> dialogContent = [
      Text("Select $label",
        style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
      ),
      SizedBox(height: 8),
      Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: selections.length,
          itemBuilder: (context, index) {
            return tileSelectBuilder(context, selections[index]);
          },
        ),
      )
    ];

    return showAdaptiveDialog<T>(
      context: context,
      builder: (BuildContext context) => FDialog.raw(
        style: dialogStyle,
        builder: (context, style) => ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width/1.2,
            maxHeight: MediaQuery.sizeOf(context).height/2
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Card(
              color: theme.colorScheme.background,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: dialogContent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AvertSelectTile<T extends Object> extends StatelessWidget {
  const AvertSelectTile({
    super.key,
    required this.title,
    required this.onPress,
    this.prefixIcon,
    this.style,
  });

  final Widget? prefixIcon;
  final VoidCallback? onPress;
  final Widget title;
  final FTileStyle? style;

  @override
  Widget build(BuildContext context) {
    FThemeData theme = FTheme.of(context);
    FTileStyle themeTileStyle = theme.tileGroupStyle.tileStyle;
    return FTile(
      style: style ?? themeTileStyle.copyWith(
        borderRadius: BorderRadius.all(Radius.zero),
        border: Border.all(width: 0)
      ),
      prefixIcon: prefixIcon,
      title: title,
      onPress: onPress,
    );
  }
}
