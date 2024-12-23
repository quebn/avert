import "package:avert/core/core.dart";
import "package:forui/forui.dart";

class AvertSelect<T extends Document> extends StatefulWidget {
  const AvertSelect({super.key,
    required this.label,
    required this.valueBuilder,
    required this.tileSelectBuilder,
    required this.controller,
    this.options = const [],
    this.description,
    this.error,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.dialogActions = const [],
  });

  final Widget label;
  final Widget Function(BuildContext context, T? selectedValue) valueBuilder;
  final FSelectTile<T> Function(BuildContext context, T value, T? currentValue) tileSelectBuilder;
  final List<T> options;
  final Widget? prefix, suffix, description, error;
  final bool enabled;
  final List<Widget> dialogActions;
  final FRadioSelectGroupController<T> controller;

  @override
  State<StatefulWidget> createState() => _SelectState<T>();
}

class _SelectState<T extends Document> extends State<AvertSelect<T>> {

  final List<FSelectTile<T>> selections = [];
  T? get currentValue => widget.controller.values.firstOrNull;

  @override
  void initState() {
    super.initState();
    if (widget.options.isNotEmpty) {
      for (T item in widget.options) {
        selections.add(widget.tileSelectBuilder(context, item, currentValue));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = FTheme.of(context);
    final FButtonCustomStyle style = theme.buttonStyles.outline;

    return FLabel(
      axis: Axis.vertical,
      label: widget.label,
      description: widget.description,
      child: FButton(
        style: style,
        onPress: widget.options.isNotEmpty ? getValueFromSelections : null,
        suffix: widget.suffix,
        prefix: widget.prefix,
        label: Expanded(
          child: widget.valueBuilder(context, currentValue),
        )
      ),
    );
  }

  Future<void> getValueFromSelections() async {
    T? selectedValue = await openSelectionDialog(selections);

    if (selectedValue != null) {
      setState(() => widget.controller.select(selectedValue, true));
    }
  }

  Future<T?> openSelectionDialog(List<FSelectTile<T>> selections) {
    printWarn("showing selection dialog");
    return showAdaptiveDialog<T>(
      context: context,
      builder: (BuildContext context) => FDialog(
        direction: Axis.vertical,
        title: widget.label,
        body: FSelectTileGroup<T>(
          divider: FTileDivider.full,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            T? selected = value?.single;
            if (selected == null) return;
            Navigator.of(context).pop(selected);
            return null;
          },
          controller: widget.controller,
          children: selections,
        ),
        actions: widget.dialogActions,
      ),
    );
  }
}
