import "package:avert/docs/document.dart";
import "package:flutter/material.dart";
import "package:forui/forui.dart";

// NOTE: bikeshed this component to be used later for reports.
class AvertTable<T extends Document> extends StatefulWidget {
  const AvertTable({
    super.key,
    required this.label,
    required this.columns,
    this.rowBuilder,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.onSaved,
    this.description,
    this.error,
    this.forceErrorText,
    this.restorationId,
    this.autovalidateMode,
    this.contents,
  });

  final String label;
  final Map<String,TableColumnWidth> columns;
  final void Function(T?)? onSaved;
  final String? forceErrorText, restorationId;
  final String? Function(T?)? validator;
  final bool enabled, required;
  final AutovalidateMode? autovalidateMode;
  final Widget? description, error;
  final Widget Function()? rowBuilder;
  final List<T>? contents;
  // final Map<int, TableColumnWidth>? columnWidths;


  @override
  State<StatefulWidget> createState() => _TableState<T>();
}

class _TableState<T extends Document> extends State<AvertTable<T>> {

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      enabled: widget.enabled,
      builder: (state) => builder(context, state),
    );
  }

  Widget builder(BuildContext context, FormFieldState state) {
    final FThemeData theme = FTheme.of(context);
    final TextStyle errorTextStyle = theme.textFieldStyle.errorStyle.labelTextStyle;
    final TextStyle enabledTextStyle = theme.textFieldStyle.enabledStyle.labelTextStyle;

    final Widget widgetLabel = RichText(
      text: TextSpan(
        style: state.hasError ? errorTextStyle : enabledTextStyle,
        text: widget.label,
        children:  widget.required ? [
          TextSpan( text: " *", style: errorTextStyle),
        ] : null,
      ),
    );
    final List<TableRow> children = [ _header ];

    final List<Widget> widgetChildren = [
      Table(
        border: TableBorder(
          bottom: BorderSide(),
          verticalInside: BorderSide(),
        ),
        columnWidths: _columnWidths,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: children
      ),
      Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: widget.contents == null || widget.contents!.isEmpty ? Text(
          "No Records Found",
          style: theme.typography.sm,
        ) : null,
      ),
    ];

    return SizedBox(
      child: FLabel(
        error: state.hasError ? Text(state.errorText!) : null,
        axis: Axis.vertical,
        label: widgetLabel,
        description: widget.description,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          child: FCard.raw(
            child: Column( children: widgetChildren),
          ),
        ),
      ),
    );
  }

  TableRow get _header {
    final FThemeData theme = FTheme.of(context);

    final List<Widget> children = [
        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text("x", style: theme.typography.sm.copyWith(
            fontWeight: FontWeight.bold
          ), textAlign: TextAlign.center),
        )
    ];
    for (String colName in widget.columns.keys.toList()) {
      children.add(
        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(colName, style: theme.typography.sm.copyWith(
            fontWeight: FontWeight.bold
          ), textAlign: TextAlign.center),
        )
      );
    }
    return TableRow(children: children);
  }

  Map<int, TableColumnWidth>? get _columnWidths {
    final List<TableColumnWidth> colWidths = widget.columns.values.toList();
    final Map<int, TableColumnWidth> columnWidths = {
      0: FixedColumnWidth(32),
    };

    int i = 1;
    for (TableColumnWidth width in colWidths) {
      columnWidths[i++] = width;
    }
    return columnWidths;
  }
}


// TODO: Impl AvertTableRow
class AvertTableRow<T extends Document> extends StatefulWidget {
  const AvertTableRow({super.key});

  @override
  State<StatefulWidget> createState() => _TableRowState<T>();
}

class _TableRowState<T extends Document> extends State<AvertTableRow<T>> {

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

