import "package:avert/core/core.dart";

class AvertDropdown extends StatefulWidget {
  const AvertDropdown({super.key,
    required this.label,
    required this.options,
    required this.controller,
    this.xPadding = 8,
    this.yPadding = 8,
    this.labelStyle,
    this.expand = false,
    this.enabled = true,
    this.onSelected,
    this.initialSelection,
    this.listener,
  });

  final String label;
  final double xPadding, yPadding;
  final TextStyle? labelStyle;
  final List<DropdownMenuEntry<dynamic>> options;
  final TextEditingController controller;
  final bool expand, enabled;
  final void Function(dynamic)? onSelected;
  final dynamic initialSelection;
  final void Function()? listener;

  @override
  State<StatefulWidget> createState() => _DropdownState();
}

class _DropdownState extends State<AvertDropdown> {

  @override
  void initState() {
    super.initState();
    if (widget.listener != null) {
      widget.controller.addListener(widget.listener!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.listener != null) {
      widget.controller.removeListener(widget.listener!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.xPadding, vertical: widget.yPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: make this into a richtext that show
          // on the label whether this field is required.
          Text(widget.label,
            style: widget.labelStyle ?? TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          DropdownMenu(
            enabled: widget.enabled,
            dropdownMenuEntries: widget.options,
            controller: widget.controller,
            onSelected: widget.onSelected,
            initialSelection: widget.initialSelection,
          )
        ],
      )
    );
    if (widget.expand) return Expanded(child: content);
    return content;
  }
}
