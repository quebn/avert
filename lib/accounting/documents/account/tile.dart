import "package:avert/core/core.dart";
import "package:forui/forui.dart";

import "document.dart";
import "view.dart";

class AccountTile extends StatefulWidget {
  const AccountTile({super.key,
    required this.document,
    required this.profile,
    required this.onDelete,
  });

  final Account document;
  final Profile profile;
  final Function() onDelete;

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
    Account? document = await Navigator.of(context).push<Account>(
      MaterialPageRoute(
        builder: (context) => AccountView(
          document: widget.document,
          profile: widget.profile,
          //onDelete: widget.onDelete,
        ),
      )
    );

    if (document != null) {
      if (_name != document.name) {
        setState(() => _name = document.name);
      }
    }
  }
}
