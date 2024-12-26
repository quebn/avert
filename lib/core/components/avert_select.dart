import "package:avert/core/core.dart";
import "package:forui/forui.dart";

class AvertSelect<T extends Object> extends StatelessWidget {
  const AvertSelect({super.key,
    required this.label,
    required this.valueBuilder,
    required this.tileSelectBuilder,
    required this.controller,
    required this.options,
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
    required this.controller,
    required this.optionsQuery,
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
  final FSelectTile<T> Function(BuildContext, T) tileSelectBuilder;
  final List<T> options;
  final Widget? prefix, suffix, description, error;
  final bool enabled, required;
  final List<Widget> dialogActions;
  final FRadioSelectGroupController<T> controller;
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
      initialValue: controller.values.firstOrNull,
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
    List<FSelectTile<T>> selections = [];
    if (optionsQuery == null) {
      _buildSelections(context, selections, options);
    } else {
      await _buildselectionsFromQuery(context, selections);
    }
    if (context.mounted) {
      T? value = await _openSelectionDialog(context, selections);
      if (value == null) return;
      state.didChange(value);
    }
  }

  Future<T?> _openSelectionDialog(BuildContext context, List<FSelectTile<T>> selections) {
    printWarn("showing selection dialog");
    return showAdaptiveDialog<T>(
      context: context,
      builder: (BuildContext context) => FDialog(
        direction: Axis.vertical,
        title: Text(label),
        actions: dialogActions,
        body: Container(
          // INFO: set set selection window max height to half of the screen
          constraints: BoxConstraints.loose(
            Size.fromHeight(MediaQuery.of(context).size.height / 2)
          ),
          child: SingleChildScrollView(
              child: FSelectTileGroup<T>(
              divider: FTileDivider.full,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                T? selected = value?.single;
                if (selected == null) return;
                Navigator.of(context).pop(selected);
                printInfo("Triggered");
                return null;
              },
              controller: controller,
              children: selections,
            ),
          ),
        ),
      ),
    );
  }

  void _buildSelections(BuildContext context, List<FSelectTile<T>> selectionList, List<T> optionsList) {
    if (optionsList.isEmpty) return;

    for (T item in optionsList) {
      selectionList.add(tileSelectBuilder(context, item));
    }
  }

  Future<void> _buildselectionsFromQuery(BuildContext context, List<FSelectTile<T>> selectionList) async {
    List<T> results = await optionsQuery!();
    if (context.mounted) _buildSelections(context, selectionList, results);
  }
}

foo() {
  TextFormField();
}
