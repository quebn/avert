import "package:avert/utils/logger.dart";
import "package:avert/utils/ui.dart";
import "package:flutter/material.dart";
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
    this.yMargin = 4,
    this.required = false,
    this.validator,
    this.onSaved,
    this.onChange,
    this.forceErrorText,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final String label;
  final Widget Function(BuildContext, T?) valueBuilder;
  final AvertSelectTile Function(BuildContext, T) tileSelectBuilder;
  final List<T> options;
  final Widget? prefix, suffix, description, error;
  final bool enabled, required;
  // final List<Widget> dialogActions;
  final void Function(T?)? onSaved;
  final String? Function(T?)? validator;
  final String? forceErrorText;
  final AvertSelectController<T> controller;
  final double yMargin;
  final AutovalidateMode? autovalidateMode;
  final void Function(T?)? onChange;

  @override
  State<StatefulWidget> createState() => _SelectState<T>();
}

class _SelectState<T extends Object> extends State<AvertSelect<T>> {
  FormFieldState<T>? formFieldState;
  List<T> get options => widget.options;

  @override
  void initState() {
    super.initState();
    widget.controller.addValueListener(updateState);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeValueListener(updateState);
  }

  void updateState(T? value) {
    formFieldState?.didChange(value);
    widget.onChange?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building Select ${widget.label}");
    return FormField<T>(
      key: widget.key,
      onSaved: widget.onSaved,
      enabled: widget.enabled,
      builder: builder,
      validator: validate,
      initialValue: widget.controller.value,
      forceErrorText: widget.forceErrorText,
      autovalidateMode: widget.autovalidateMode,
    );
  }

  Widget builder(FormFieldState<T> state) {
    formFieldState = state;
    printAssert(state.value == widget.controller.value,"Select state value does not match the controller value: controller->${widget.controller.value.toString()} state->${state.value.toString()}");
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

    FLabelState labelState = options.isNotEmpty ? FLabelState.enabled : FLabelState.disabled;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.yMargin),
      child: FLabel(
        state: state.hasError ? FLabelState.error : labelState,
        error: Text(state.errorText ?? ""),
        axis: Axis.vertical,
        label: RichText(
          text: TextSpan(
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
          onPress: widget.enabled && options.isNotEmpty ? () async => select(context) : null,
          suffix: widget.suffix,
          prefix: widget.prefix,
          label: Expanded(
            child: widget.valueBuilder(context, state.value),
          )
        ),
      ),
    );
  }

  String? validate(T? value) {
    if (widget.required && value == null) return "${widget.label} is required!";
    return widget.validator?.call(value);
  }

  Future<void> select(BuildContext context) async {
    if (options.isEmpty) {
      notify(context, "${widget.label}: No available selections!");
      return;
    }
    T? value = await openSelectionDialog(context);
    if (value != null) widget.controller.update(value);
  }


  Future<T?> openSelectionDialog(BuildContext context) {
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
        margin: EdgeInsets.only(top: 8),
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
  final List<void Function(T?)> _valueListeners = [];

  T? get value => this._value;

  bool update(T? value) {
    if (_value == value) {
      onUpdate?.call(_value, false);
      return false;
    }
    _value = value;
    onUpdate?.call(_value, true);
    for (void Function(T?) listener in _valueListeners) {
      listener.call(_value);
    }
    return true;
  }

  void addValueListener(void Function(T?) valueListener) {
    _valueListeners.add(valueListener);
  }

  void removeValueListener(void Function(T?) valueListener) {
    _valueListeners.remove(valueListener);
  }
}
