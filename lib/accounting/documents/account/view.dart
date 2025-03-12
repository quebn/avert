import "package:avert/core/components/document.dart";
import "package:avert/core/core.dart";
import "package:avert/core/utils/ui.dart";
import "package:forui/forui.dart";

import "document.dart";
import "form.dart";

// TODO: display ff.
// [ ] type
// [ ] root
// [ ] parent
// [ ] children as table (or list).

class AccountView extends StatefulWidget {
  const AccountView({ super.key,
    required this.document,
  });

  final Account document;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<AccountView> with SingleTickerProviderStateMixin implements DocumentView<Account>  {
  late final FPopoverController _controller;

  @override
  late Account document = widget.document;

  @override
  void initState() {
    super.initState();
    _controller = FPopoverController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = FTheme.of(context);
    final FCardContentStyle contentStyle = theme.cardStyle.contentStyle;

    final SvgAsset icon = document.isGroup ? FAssets.icons.folder : FAssets.icons.file;

    final List<Widget> header = [
      Row( children:[
        FIcon(icon),
        SizedBox(width: 8),
        Text(document.name, style: contentStyle.titleTextStyle),
      ]),
      Row( children: [
      ]),
    ];
    printTrack("Building Account Document View");
    return AvertDocumentView<Account>(
      controller: _controller,
      name: "Account",
      header: header,
      editDocument: editDocument,
      deleteDocument: deleteDocument,
      content: Container(),
    );
  }

  @override
  void editDocument() async {
   await Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => AccountForm(
        document: document,
        onSubmit: _onEdit,
      ),
    ));

    if (document.action == DocAction.none) return;
    if (document.action == DocAction.update) {
      throw UnimplementedError("Should update the View");
    }
  }

  Future<bool> _onEdit(Account document) async  {
    throw UnimplementedError();
    // String msg = "Error writing the document to the database!";
    //
    // bool success = true;//await account.update();
    // if (success) msg = "Successfully changed account details";
    //if (mounted) notify(context, msg);
    //
    //return success;
  }

  Future<bool?> _confirmDelete() {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (BuildContext context) => FDialog(
        direction: Axis.horizontal,
        title: Text("Delete '${document.name}'?"),
        body: const Text("Are you sure you want to delete this Account?"),
        actions: <Widget>[
          FButton(
            label: const Text("No"),
            style: FButtonStyle.outline,
            onPress: () {
              Navigator.of(context).pop(false);
            },
          ),
          FButton(
            style: FButtonStyle.destructive,
            label: const Text("Yes"),
            onPress: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }

  @override
  Future<void> deleteDocument() async {
    bool hasChild = await document.hasChild;
    if (hasChild) {
      if (mounted) notify(context, "Could not delete: '${document.name}' has child accounts");
      return;
    }
    final bool shouldDelete = await _confirmDelete() ?? false;

    if (shouldDelete) {
      final bool success = await document.delete();

      if (!success) {
        if (mounted) notify(context, "Could not delete: '${document.name}' can't be deteled in database!");
        return;
      }
      printWarn("Deleting Account:${document.name} with id of: ${widget.document.id}");
      if (mounted) Navigator.of(context).pop();
    }
  }
}
