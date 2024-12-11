import "package:avert/core/core.dart";

class AvertList extends StatefulWidget {
  const AvertList({super.key,
    required this.label,
    required this.dataBuilder,
    this.initialData,
    this.labelStyle,
    this.xPadding = 8,
    this.yPadding = 8,
    this.border,
    this.header,
    this.required = false,
  });

  final List<dynamic>? initialData;
  final String label;
  final TextStyle? labelStyle;
  final double xPadding, yPadding;
  final AvertListTile Function(int, dynamic) dataBuilder;
  final BoxBorder? border;
  final List<String>? header;
  final bool required;

  @override
  State<StatefulWidget> createState() => _ListState();
}

class _ListState extends State<AvertList> {
  List<AvertListTile> list = [];

  @override
  initState() {
    super.initState();
    createInitialRows();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building AvertListTile");
    printInfo("List length: ${list.length}");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.xPadding, vertical: widget.yPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RichText(
            text: TextSpan(
              text: widget.label,
              style:widget.labelStyle ?? TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black
              ),
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
          Container(
            margin: EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: widget.border ?? Border.all(width: 1),
            ),
            height: list.isEmpty ? 100 : null,
            child: list.isEmpty ? Center(
              child: Text("List is Empty :(",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ) : Column( children: list),
          ),
        ]
      ),
    );
  }

  void createInitialRows() {
    if (widget.initialData == null) return;

    for ((int, dynamic) data in widget.initialData!.indexed) {
      list.add(widget.dataBuilder(data.$1 + 1, data.$2));
    }
  }
}

class AvertListTile extends StatelessWidget {
  const AvertListTile({super.key,
    required this.index,
    required this.title,
    this.subtitle,
    this.prefix,
    this.suffix,
    this.xMargin = 0,
    this.yMargin = 0,
    this.xPadding = 8,
    this.yPadding = 8,
    this.border,
  });

  final int index;
  final double xPadding, yPadding;
  final double xMargin, yMargin;
  final Widget title;
  final Widget? subtitle, prefix, suffix;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: xMargin, vertical: yMargin),
      padding: EdgeInsets.symmetric(horizontal: xPadding, vertical: yPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: border ?? Border.all(width: 1),
      ),
      child: SizedBox(
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text("$index.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24
                ),
              ),
            ),
            SizedBox(
              child: prefix),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, SizedBox(child: subtitle)],
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(left: 8),
                    child: suffix,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
