import "package:avert/core/components/avert_document.dart";
import "package:avert/core/core.dart";
import "package:avert/core/utils/ui.dart";
import "package:forui/forui.dart";

import "form.dart";

class ProfileView extends StatefulWidget {
  const ProfileView({super.key,
    required this.document,
    required this.profile,
    //required this.deleteDocument,
  });

  final Profile document, profile;
  //final Function() deleteDocument;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<ProfileView> with SingleTickerProviderStateMixin implements DocumentView<Profile> {
  late final FPopoverController _controller;

  @override
  late Profile document = widget.document;

  @override
  Result<Profile> result = Result<Profile>(null);

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
    printTrack("Building Profile Document View");
    return AvertDocumentView<Profile>(
      result: result,
      controller: _controller,
      name: "Profile",
      title: document.name,
      subtitle: document != widget.profile ? "Current Profile" : "Profile",
      editDocument: editDocument,
      deleteDocument: deleteDocument,
      content: Container(),
    );
  }

  @override
  Future<void> deleteDocument() async {
    final bool shouldDelete = await _confirmDelete() ?? false;

    if (shouldDelete) {
      result = await document.delete();

      if (result.isEmpty) return;

      printWarn("Deleting Profile:${document.name} with id of: ${document.id}");
      if (mounted) Navigator.of(context).pop<Result<Profile>>(result);
    }
  }

  @override
  void editDocument() async {
    result = await Navigator.of(context).push<Result<Profile>>(
      MaterialPageRoute(
        builder: (BuildContext context) => ProfileForm(
          document: document,
          onSubmit: _onEdit,
        ),
      )
    ) ?? Result.empty();

    if (result.isEmpty) return;
    if (result.action == DocumentAction.update) {
      setState(() => document = result.document!);
    }
  }

  Future<Result<Profile>> _onEdit() async {
    // NOTE: add checks here.
    String msg = "Error writing the document to the database!";

    final Result<Profile> result = await document.update();

    if (!result.isEmpty) msg = "Successfully changed profile details";

    if (mounted) notify(context, msg);

    return result;
  }

  Future<bool?> _confirmDelete() {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (BuildContext context) => FDialog(
        direction: Axis.horizontal,
        title: Text("Delete '${widget.document.name}'?"),
        body: const Text("Are you sure you want to delete this Profile?"),
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

}
