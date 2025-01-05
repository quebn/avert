import "package:avert/core/core.dart";
import "package:forui/forui.dart";

class AvertListScreen<T extends Document> extends StatefulWidget {
  const AvertListScreen({super.key,
    required this.initialList,
    required this.tileBuilder,
    required this.title,
    required this.createDocument,
  });

  final Widget title;
  final List<T> initialList;
  final Widget Function(ObjectKey, BuildContext, T, void Function(T)) tileBuilder;
  final void Function(void Function(T))? createDocument;

  @override
  State<StatefulWidget> createState() => _ListScreenState<T>();
}

class _ListScreenState<T extends Document> extends State<AvertListScreen<T>> {
  List<T> list = [];

  @override
  void initState() {
    super.initState();
    list.addAll(widget.initialList);
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building ${widget.title} Tile List Screen");
    FThemeData theme = FTheme.of(context);
    return Scaffold(
      floatingActionButton: widget.createDocument != null ? FButton.icon(
        onPress: () => widget.createDocument!(_addDocument),
        style: theme.buttonStyles.primary.copyWith(
          enabledBoxDecoration: theme.buttonStyles.primary.enabledBoxDecoration.copyWith(
            borderRadius: BorderRadius.circular(33),
          )
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: FIcon(FAssets.icons.listPlus,
            size: 32,
          ),
        )
      ) : null,
      backgroundColor: theme.scaffoldStyle.backgroundColor,
      body: FScaffold(
        header: FHeader.nested(
          title: widget.title,
          suffixActions: [], // TODO: create sufficAction that brings user back to top.
          prefixActions: [
            FHeaderAction(
              icon: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: FIcon(FAssets.icons.chevronLeft),
              ),
              onPress: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
        style: theme.scaffoldStyle,
        content: ListView.builder(
          //findChildIndexCallback:,
          itemCount: list.length,
          itemBuilder: (context, index) {
            T document = list[index];
            return widget.tileBuilder(ObjectKey(document), context, document, _removeDocument);
          },
        ),
      ),
    );
  }

  //void _createDocument() async {
  //  final Result<T> result = await Navigator.of(context).push<Result<T>>(
  //    MaterialPageRoute(
  //      builder: (context) => widget.formBuilder(context),
  //    )
  //  ) ?? Result<T>.empty();
  //  if (result.isEmpty) return;
  //  printImplement("should add document to list");
  //  //throw UnimplementedError("should add document to list");
  //  // TODO: this should only expect a document if there is document returned add, else dont,
  //
  //}

  void _addDocument(T document) {
    if (list.contains(document)) return;
    setState(() => list.add(document));
  }

  void _removeDocument(T document) {
    if (!list.contains(document)) return;
    setState(() => list.remove(document));
  }
}
