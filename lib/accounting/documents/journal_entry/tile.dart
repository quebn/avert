import "package:avert/core/core.dart";
import "package:forui/forui.dart";

import "document.dart";
// import "view.dart";

class JournalEntryTile extends StatefulWidget {
  const JournalEntryTile({super.key,
    required this.document,
    required this.profile,
    required this.removeDocument,
  });

  final JournalEntry document;
  final Profile profile;
  final void Function(JournalEntry) removeDocument;

  @override
  State<StatefulWidget> createState() => _TileState();
}

class _TileState extends State<JournalEntryTile> {
  late String _name = widget.document.name;
  // late String _root = widget.document.root.toString();
  // late SvgAsset _icon = widget.document.isGroup ? FAssets.icons.folder : FAssets.icons.file;

  @override
  Widget build(BuildContext context) {
    printTrack("build account tile with name of :${widget.document.name}");
    final FThemeData theme = FTheme.of(context);
    return ListTile(
      // leading: FIcon(_icon),
      // subtitle: Text(_root, style: theme.typography.sm),
      title: Text(_name, style: theme.typography.base),
      onTap: _viewAccount,
    );
  }

  void _viewAccount() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Container(
          // document: widget.document,
        ),
      )
    );

    if (widget.document.action == DocAction.none) return;

    switch (widget.document.action) {
      case DocAction.update: {
        setState(() => _name = widget.document.name);
      } break;
      case DocAction.delete: {
        widget.removeDocument(widget.document);
      } break;
      default: break;
    }
  }
}
