import "package:avert/docs/document.dart";
import "package:avert/utils/logger.dart";
import "package:flutter/material.dart";
import "package:forui/forui.dart";

class AvertListField<T extends Document> extends StatefulWidget {
  const AvertListField({super.key,
    required this.label,
    required this.tileBuilder,
    required this.controller,
    required this.list,
    this.onNewItem,
    this.description,
    this.onChange,
    this.error,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.forceErrorText,
    this.yMargin = 4,
    this.initialValues,
  });

  final String label;
  final Widget Function(BuildContext, T, int) tileBuilder;
  final Widget? description, error;
  final bool enabled, required;
  final String? Function(List<T>?)? validator;
  final String? forceErrorText;
  final Function(T)? onChange;
  final List<T> list;
  final void Function()? onNewItem;
  final double yMargin;
  final AvertListFieldController<T> controller;
  final List<T>? initialValues;

  @override
  State<StatefulWidget> createState() => _ListFieldState<T>();
}

class _ListFieldState<T extends Document> extends State<AvertListField<T>> {
  int updateCount = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addValueListener((values, value) {
      widget.onChange?.call(value);
      setState(() => updateCount++);
    });
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
      initialValue: widget.initialValues,
      forceErrorText: widget.forceErrorText,
    );
  }

  Widget builder(FormFieldState<List<T>> state) {
    final FThemeData theme = FTheme.of(context);
    List<Widget> children = [], list = [];
    int count = 0;
    for (T item in widget.controller.values) {
      list.add(widget.tileBuilder(context, item, count++));
    }
    if (list.isNotEmpty) children = list;

    final FButtonStyle ghostStyle = theme.buttonStyles.ghost;
    final List<Widget> label = [
      RichText(
        text: TextSpan(
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
          onPress: widget.onNewItem,
          child: FIcon(FAssets.icons.listPlus),
        ),
      ),
    ];

    final FCardStyle errorStyle = theme.cardStyle.copyWith(
      decoration: theme.cardStyle.decoration.copyWith(
        border: Border.all(
          color: theme.colorScheme.destructive
        )
      )
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.yMargin),
      child: FLabel(
        state: state.hasError ? FLabelState.error : FLabelState.enabled,
        error: Text(state.errorText ?? ""),
        axis: Axis.vertical,
        label: Row( spacing: 12, children: label),
        description: widget.description,
        child: FCard.raw(
          style: state.hasError ? errorStyle : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(children.isEmpty ? 0 : 8),
                child: Column(
                  children: children,
                ),
              ),
              SizedBox(
                child: children.isEmpty ? null : Divider(
                  height: 1,
                  color: state.hasError ? theme.colorScheme.destructive : theme.dividerStyles.horizontalStyle.color
                ),
              ),
              newItemButton(context)
            ]
          ),
        ),
      ),
    );
  }

  Widget newItemButton(BuildContext context) {
    final FThemeData theme = context.theme;
    final TextStyle textStyle = theme.buttonStyles.ghost.contentStyle.enabledTextStyle;
    return SizedBox(
      child: FButton(
        prefix: FIcon(FAssets.icons.plus),
        style: FButtonStyle.ghost,
        onPress: widget.onNewItem,
        label: Text("Add New Item", style: textStyle.copyWith(
          fontSize: theme.typography.sm.fontSize,
        )),
      ),
    );
  }

  String? validate(List<T>? values) {
    if (widget.required && (values == null || values.isEmpty)) return "${widget.label} is required!";
    return widget.validator?.call(values);
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
    this.details,
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
  final Widget? details;
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
      details: details,
      onPress: () => onPress?.call(),
    );
  }
}

class AvertListFieldController<T extends Object> {
  AvertListFieldController({
    required List<T> values,
  }):_values = values;

  final List<T> _values;
  final List<Function> _listeners = [];
  final List<T> _removed = [];

  List<T> get values => _values;
  List<T> get cachedRemoved => _removed;
  List<T> get valuesWithCachedRemoved => _values + _removed;

  bool add(T value) {
    if (_values.contains(value)) return false;
    _values.add(value);
    for (Function listener in _listeners) {
      listener.call(_values, value);
    }
    return true;
  }

  bool remove(T value, {bool hardRemove = false}) {
    if (!_values.contains(value)) {
      printAssert(!hardRemove && _removed.contains(value), "Error ListField Controller remove error value:${value.toString()} was not cached when removed");
      return false;
    }
    _values.remove(value);
    if (!hardRemove) _removed.add(value);
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
