import "package:avert/core/components/avert_document.dart";
import "package:avert/core/core.dart";
import "package:avert/core/utils/ui.dart";
import "package:forui/forui.dart";

import "document.dart";
import "form.dart";

class AccountView extends StatefulWidget {
  const AccountView({super.key,
    required this.document,
    required this.profile,
    required this.onDelete,
  });

  final Profile profile;
  final Account document;
  final Function() onDelete;

  @override
  State<StatefulWidget> createState() => _ViewState();

}

class _ViewState extends State<AccountView> with SingleTickerProviderStateMixin implements DocumentView<Account>  {
  late final FPopoverController _controller;

  @override
  late Account document = widget.document;

  @override
  bool edited = false;

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
    printTrack("Building Account Document View");
    printInfo("profile.id = ${document.id}");
    printInfo("profile.name = ${document.name}");
    return AvertDocumentView<Account>(
      result: getResult(this),
      controller: _controller,
      name: "Account",
      title: document.name,
      editDocument: editDocument,
      deleteDocument: deleteDocument,
      content: Container(),
    );
  }

  @override
  void editDocument() {
    Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) => AccountForm(
        profile: widget.profile,
        document: document,
        onSubmit: _onEdit,
      ),
    ));
  }

  Future<bool> _onEdit() async  {
    String msg = "Error writing the document to the database!";

    bool success = true;//await account.update();

    if (success) msg = "Successfully changed account details";
    if (mounted) notify(context, msg);

    return success;
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
      if (mounted) notify(context, "Could not delete account: ${document.name} has child accounts");
      return;
    }
    final bool shouldDelete = await _confirmDelete() ?? false;

    printError("print if success: $shouldDelete");
    if (shouldDelete) {
      final bool success = await document.delete();

      if (success) {
        printWarn("Deleting Account:${document.name} with id of: ${widget.document.id}");

        if (mounted) Navigator.of(context).pop<Account>(null);

        widget.onDelete();
      } else {
        if (mounted) notify(context, "Could not delete account: ${document.name} deletion failed!");
      }
    }
  }
}
