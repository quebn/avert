import "package:avert/accounting/utils/common.dart";
import "package:avert/core/core.dart";
import "package:forui/forui.dart";

import "document.dart";

class AccountTile extends StatefulWidget {
  const AccountTile({super.key,
    required this.document,
    required this.profile,
    required this.removeDocument,
  });

  final Account document;
  final Profile profile;
  final void Function(Account) removeDocument;

  @override
  State<StatefulWidget> createState() => _TileState();
}

class _TileState extends State<AccountTile> {
  late String _name = widget.document.name;
  late String _root = widget.document.root.toString();
  late SvgAsset _icon = widget.document.isGroup ? FAssets.icons.folder : FAssets.icons.file;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = FTheme.of(context);
    printTrack("build account tile with name of :${widget.document.name}");
    return ListTile(
      leading: FIcon(_icon),
      subtitle: Text(_root, style: theme.typography.sm),
      title: Text(_name, style: theme.typography.base),
      onTap: widget.document.isGroup ? _viewChildren : _viewAccount,
    );
  }

  void _viewChildren() async {
    // TODO: Implement method
    throw UnimplementedError("expand list of childrens");
  }

  void _viewAccount() async {
    final Result<Account> result = await viewAccount(context, widget.document);
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
