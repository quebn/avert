import "package:avert/core/core.dart";
import "package:avert/core/utils/ui.dart";
import "package:forui/forui.dart";

class AvertSelect<T extends Object> extends StatefulWidget {
  const AvertSelect({super.key,
    required this.label,
    required this.valueBuilder,
    required this.tileSelectBuilder,
    required this.options,
    required this.controller,
    this.description,
    this.error,
    this.prefix,
    this.suffix,
    this.enabled = true,
    // this.dialogActions = const [],
    this.flex = 0,
    this.required = false,
    this.validator,
    this.onSaved,
    this.forceErrorText,
  });

  final String label;
  final Widget Function(BuildContext, T?) valueBuilder;
  final AvertSelectTile Function(BuildContext, T) tileSelectBuilder;
  final List<T> options;
  final Widget? prefix, suffix, description, error;
  final bool enabled, required;
  // final List<Widget> dialogActions;
  final int flex;
  final void Function(T?)? onSaved;
  final String? Function(T?)? validator;
  final String? forceErrorText;
  final AvertSelectController<T> controller;

  @override
  State<StatefulWidget> createState() => _SelectState<T>();
}

class _SelectState<T extends Object> extends State<AvertSelect<T>> {
  FormFieldState<T>? _state;
  List<T> get options => widget.options;

  @override
  void initState() {
    super.initState();
    widget.controller.addValueListener(_updateState);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeValueListener(_updateState);
  }

  void _updateState() {
    // printSuccess("Updating state on label: ${widget.label}");
    _state?.didChange(widget.controller.value);
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building Select ${widget.label}");
    return FormField<T>(
      key: widget.key,
      onSaved: widget.onSaved,
      enabled: widget.enabled,
      builder: _builder,
      validator: _validate,
      initialValue: widget.controller.value,
      forceErrorText: widget.forceErrorText,
    );
  }

  Widget _builder(FormFieldState<T> state) {
    _state = state;
    printAssert(state.value == widget.controller.value,"Select state value does not match the controller value: controller->${widget.controller.value.toString()} state->${state.value.toString()}");
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
      flex: widget.flex,
      child: FLabel(
        error: state.hasError ? Text(state.errorText!) : null,
        axis: Axis.vertical,
        label: RichText(
          text: TextSpan(
            style: state.hasError ? errorTextStyle : enabledTextStyle,
            text: widget.label,
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
        ),
        description: widget.description,
        child: FButton(
          style: state.hasError ? errstyle : style,
          onPress: widget.enabled && options.isNotEmpty ? () async => _select(context) : null,
          suffix: widget.suffix,
          prefix: widget.prefix,
          label: Expanded(
            child: widget.valueBuilder(context, state.value),
          )
        ),
      ),
    );
  }

  String? _validate(T? value) {
    if (widget.required && value == null) return "${widget.label} is required!";
    return widget.validator == null ? null : widget.validator!(value);
  }

  Future<void> _select(BuildContext context) async {
    if (options.isEmpty) {
      notify(context, "${widget.label}: No available selections!");
      return;
    }
    T? value = await _openSelectionDialog(context);
    if (value != null) widget.controller.update(value);
  }


  Future<T?> _openSelectionDialog(BuildContext context) {
    final FThemeData theme = FTheme.of(context);
    FDialogStyle dialogStyle = theme.dialogStyle.copyWith(
      decoration: theme.dialogStyle.decoration.copyWith(
        border: Border.all(color: theme.colorScheme.border, width: 2)
      ),
    );

    final List<Widget> dialogContent = [
      Text("Select ${widget.label}",
        style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
      ),
      SizedBox(height: 8),
      Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) {
            return widget.tileSelectBuilder(context, options[index]);
          },
        ),
      ),
      Container(
        child: (widget.required) ? null : FButton(
          style: FButtonStyle.destructive,
          onPress: () {
            widget.controller.update(null);
            Navigator.of(context).pop<T?>(null);
          },
          label: const Text("Deselect"),
        ),
      ),
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
    required this.value,
    this.onPress,
    this.subtitle,
    this.prefix,
    this.suffix,
    this.style,
  });

  final T value;
  final VoidCallback? onPress;
  final Widget title;
  final Widget? subtitle;
  final Widget? prefix;
  final Widget? suffix;
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
      prefixIcon: prefix,
      suffixIcon: suffix,
      title: title,
      subtitle: subtitle,
      onPress: () {
        onPress?.call();
        Navigator.of(context).pop<T?>(value);
      }
    );
  }
}

class AvertSelectController<T extends Object> {
  AvertSelectController({
    T? value,
    this.onUpdate,
  }):_value = value;

  T? _value;
  Function(T?, bool)? onUpdate;
  final List<Function> _listeners = [];

  T? get value => this._value;

  bool update(T? value) {
    if (_value == value) {
      onUpdate?.call(_value, false);
      return false;
    }
    _value = value;
    onUpdate?.call(_value, true);
    for (Function listener in _listeners) {
      listener.call();
    }
    return true;
  }

  void addValueListener(Function valueListener) {
    _listeners.add(valueListener);
  }

  void removeValueListener(Function valueListener) {
    _listeners.remove(valueListener);
  }
}
