import "package:avert/docs/document.dart";
import "package:avert/utils/logger.dart";
import "package:flutter/material.dart";
import "package:forui/forui.dart";

// TODO: things to implement
// - [x] empty state view.
// - [x] non-empty state view.
// - [ ] 'new item' button.
class AvertListField<T extends Document> extends StatefulWidget {
  const AvertListField({super.key,
    required this.label,
    required this.tileBuilder,
    required this.controller,
    required this.list,
    required this.addDialogFormBuilder,
    this.description,
    this.onChange,
    this.error,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.forceErrorText,
    this.yMargin = 4,
  });

  final String label;
  final Widget Function(BuildContext, T) tileBuilder;
  final Widget? description, error;
  final bool enabled, required;
  final String? Function(List<T>?)? validator;
  final String? forceErrorText;
  final Function(T)? onChange;
  final List<T> list;
  final Widget Function(BuildContext) addDialogFormBuilder;
  final double yMargin;
  final AvertListFieldController<T> controller;

  @override
  State<StatefulWidget> createState() => _ListFieldState<T>();
}

class _ListFieldState<T extends Document> extends State<AvertListField<T>> {
  // FormFieldState<List<T>>? _state;
  List<Widget> children = [];

  @override
  void initState() {
    super.initState();
    List<Widget> list = [];
    for (T item in widget.controller.values) {
      list.add(widget.tileBuilder(context, item));
    }
    if (list.isNotEmpty) setState(() => children = list);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building ListField ${widget.label}");
    return FormField<List<T>>(
      key: widget.key,
      enabled: widget.enabled,
      builder: builder,
      validator: validate,
      // initialValue: widget.controller.value,
      forceErrorText: widget.forceErrorText,
    );
  }

  Widget builder(FormFieldState<List<T>> state) {
    // _state = state;
    // printAssert(state.value == widget.controller.value,"List Field state value does not match the controller value: controller->${widget.controller.value.toString()} state->${state.value.toString()}");
    final FThemeData theme = FTheme.of(context);

    final TextStyle enabledTextStyle = theme.textFieldStyle.enabledStyle.labelTextStyle.copyWith(fontWeight: FontWeight.normal);
    final TextStyle errorTextStyle = theme.textFieldStyle.errorStyle.labelTextStyle;
    final FButtonStyle ghostStyle = theme.buttonStyles.ghost;
    final List<Widget> label = [
      RichText(
        text: TextSpan(
          style: state.hasError ? errorTextStyle : enabledTextStyle,
          text: widget.label,
          children: widget.required ? const [
            TextSpan(
              text: " *",
              style: TextStyle(color: Colors.red)
            ),
          ] : null,
        ),
      ),
      SizedBox(
        child: FButton.raw(
          style: ghostStyle,
          onPress: addToList,
          child: FIcon(FAssets.icons.listPlus),
        ),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.yMargin),
      child: FLabel(
        error: state.hasError ? Text(state.errorText!) : null,
        axis: Axis.vertical,
        label: Row( spacing: 12, children: label),
        description: widget.description,
        child: FCard.raw(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(children.isEmpty ? 0 : 8),
                child: Column(
                  children: children
                ),
              ),
              SizedBox(
                child: children.isEmpty ? null : Divider(
                  height: 1,
                  color: theme.dividerStyles.horizontalStyle.color
                ),
              ),
              newItemButton(context)
            ]
          ),
        ),
      ),
    );
  }

  void addToList() async {
    printInfo("Adding Document to List");
    final T? entry = await showAdaptiveDialog<T>(
      context: context,
      builder: widget.addDialogFormBuilder,
    );
    if (entry == null || entry.action != DocAction.insert) return;
    if (entry.action == DocAction.insert) {
      widget.controller.add(entry);
      widget.onChange?.call(entry);
      setState(() {
        children.add(widget.tileBuilder(context, entry));
      });
    }
  }

  Widget newItemButton(BuildContext context) {
    final FThemeData theme = context.theme;
    final TextStyle textStyle = theme.buttonStyles.ghost.contentStyle.enabledTextStyle;
    return SizedBox(
      child: FButton(
        prefix: FIcon(FAssets.icons.plus),
        style: FButtonStyle.ghost,
        onPress: addToList,
        label: Text(
          "Add New Item",
          style: textStyle.copyWith(
            fontSize: theme.typography.sm.fontSize,
          )
        ),
      ),
    );
  }

  String? validate(List<T>? value) {
    if (widget.required && (value == null || value.isEmpty)) return "${widget.label} is required!";
    return widget.validator?.call(value);
  }
}

class AvertListFieldTile<T extends Object> extends StatelessWidget {
  const AvertListFieldTile({
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
    final FTileStyle styleListFielded = selectedStyle ?? theme.tileGroupStyle.tileStyle.copyWith(
      enabledBackgroundColor: theme.tileGroupStyle.tileStyle.enabledHoveredBackgroundColor
    );
    return FTile(
      style: selected ? styleListFielded : styleNormal,
      prefixIcon: prefix,
      suffixIcon: suffix,
      title: title,
      subtitle: subtitle,
      onPress: null,
    );
  }
}

class AvertListFieldController<T extends Object> {
  AvertListFieldController({
    required List<T> values,
    Function(T)? onAdd,
  }):_values = values, _onAdd = onAdd;

  final List<T> _values;
  Function(T)? _onAdd;
  final List<Function> _listeners = [];

  List<T> get values => this._values;

  bool add(T value) {
    if (_values.contains(value)) {
      // throw StateError("value already exist in the list");
      return false;
    }
    _values.add(value);
    _onAdd?.call(value);
    for (Function listener in _listeners) {
      listener.call(_values, value);
    }
    return true;
  }

  void addValueListener(Function(List<T>, T) valueListener) {
    _listeners.add(valueListener);
  }

  void removeValueListener(Function(List<T>, T) valueListener) {
    _listeners.remove(valueListener);
  }
}
