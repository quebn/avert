import "package:avert/core/core.dart";
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
  final FCalendarController controller;

  @override
  State<StatefulWidget> createState() => _SelectState();
}

class _SelectState<T extends Object> extends State<AvertDTPicker> {

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
    printTrack("Building Select ${widget.label}");
    return FormField<T>(
      key: widget.key,
      enabled: widget.enabled,
      builder: _builder,
      validator: _validate,
      // initialValue: widget.controller.value,
      forceErrorText: widget.forceErrorText,
    );
  }

  Widget _builder(FormFieldState<T> state) {
    final FThemeData theme = FTheme.of(context);
    final FButtonStyle style = theme.buttonStyles.outline;
    final FButtonStyle errstyle = theme.buttonStyles.outline.copyWith(
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
          onPress: widget.enabled ? () async => _select(context) : null,
          suffix: widget.suffix,
          prefix: widget.prefix,
          label: Expanded(
            child: Text("Date Time"),
          )
        ),
      ),
    );
  }

  String? _validate(T? value) {
    if (widget.required && value == null) return "${widget.label} is required!";
    return widget.validator?.call();
  }

  Future<void> _select(BuildContext context) async {
    T? _ = await _openSelectionDialog(context);
    // if (value != null) widget.controller.update(value);
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
      FCalendar(controller: widget.controller),
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
    this.tileStyle,
    this.selectedStyle,
    this.selected = false,
  });

  final T value;
  final VoidCallback? onPress;
  final Widget title;
  final Widget? subtitle;
  final Widget? prefix;
  final Widget? suffix;
  final FTileStyle? tileStyle;
  final FTileStyle? selectedStyle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = FTheme.of(context);
    final FTileStyle styleNormal = tileStyle ?? theme.tileGroupStyle.tileStyle.copyWith(
      border: Border.all(width: 0),
    );
    final FTileStyle styleSelected = selectedStyle ?? theme.tileGroupStyle.tileStyle.copyWith(
      enabledBackgroundColor: theme.tileGroupStyle.tileStyle.enabledHoveredBackgroundColor
    );
    return FTile(
      style: selected ? styleSelected : styleNormal,
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
