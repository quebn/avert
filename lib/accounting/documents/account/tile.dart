import "package:avert/core/core.dart";
import "package:forui/forui.dart";

import "document.dart";
import "view.dart";

class AccountTile extends StatefulWidget {
  const AccountTile({super.key,
    required this.document,
    required this.profile,
    required this.removeDocument,
  });

  final Account document;
  final Profile profile;
  final Function(Account) removeDocument;

  @override
  State<StatefulWidget> createState() => _TileState();
}

class _TileState extends State<AccountTile> {
  late String _name = widget.document.name;
  late String _root = widget.document.root.toString();
  late SvgAsset _icon = widget.document.isGroup ? FAssets.icons.folder : FAssets.icons.file;

  @override
  Widget build(BuildContext context) {
    printTrack("build account tile with name of :${widget.document.name}");
    return FTile(
      prefixIcon: FIcon(_icon),
      subtitle: Text(_root),
      title: Text(_name),
      onPress: _viewProfile,
    );
  }

  void _viewProfile() async {
    final Result<Account> result = await Navigator.of(context).push<Result<Account>>(
      MaterialPageRoute(
        builder: (context) => AccountView(
          document: widget.document,
          profile: widget.profile,
        ),
      )
    ) ?? Result.empty();

    if (result.isEmpty) return;

    switch (result.action) {
      case DocumentAction.update:
        setState(() => _name = result.document!.name);
        break;
      case DocumentAction.delete:
        widget.removeDocument(result.document!);
        break;
      default:
        break;
    }
  }
}
