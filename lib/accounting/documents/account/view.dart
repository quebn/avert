import "package:avert/core/components/avert_document.dart";
import "package:avert/core/core.dart";
import "package:avert/core/utils/ui.dart";
import "package:forui/forui.dart";

import "document.dart";
import "form.dart";

class AccountView extends StatefulWidget {
  const AccountView({super.key,
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
  Result<Account> result = Result.empty();

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
    return AvertDocumentView<Account>(
      result: result,
      controller: _controller,
      name: "Account",
      title: document.name,
      editDocument: editDocument,
      deleteDocument: deleteDocument,
      content: Container(),
    );
  }

  @override
  void editDocument() async {
    Result<Account>? result = await Navigator.of(context).push<Result<Account>>(MaterialPageRoute(
      builder: (BuildContext context) => AccountForm(
        document: document,
        onSubmit: _onEdit,
      ),
    ));

    if (result == null || result.isEmpty) return;
    if (result.action == DocumentAction.update) {
      throw UnimplementedError("Should update the View");
    }
  }

  Future<Result<Account>> _onEdit(Account document) async  {
    throw UnimplementedError();
    //String msg = "Error writing the document to the database!";
    //
    //bool success = true;//await account.update();
    //
    //if (success) msg = "Successfully changed account details";
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
      final Result<Account> result = await document.delete();

      if (result.isEmpty) {
        if (mounted) notify(context, "Could not delete: '${document.name}' can't be deteled in database!");
        return;
      }
      printWarn("Deleting Account:${document.name} with id of: ${widget.document.id}");
      if (mounted) Navigator.of(context).pop<Result<Account>>(result);
    }
  }
}
