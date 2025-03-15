import "package:avert/accounting/documents/account/document.dart";
import "package:avert/core/components/document.dart";
import "package:avert/core/core.dart";
import "package:avert/core/utils/ui.dart";
import "package:forui/forui.dart";

import "form.dart";

class ProfileView extends StatefulWidget {
  const ProfileView({super.key,
    required this.document,
    required this.profile,
  });

  final Profile document, profile;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<ProfileView> with SingleTickerProviderStateMixin implements DocumentView<Profile> {
  late final FPopoverController _controller;

  @override
  late Profile document = widget.document;

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
    printTrack("Building Profile Document View");
    final List<Widget> header = [
      Text(document.name, style: contentStyle.titleTextStyle),
      Text("", style: contentStyle.subtitleTextStyle),
    ];
    return AvertDocumentView<Profile>(
      controller: _controller,
      name: "Profile",
      header: header,
      editDocument: editDocument,
      deleteDocument: deleteDocument,
      content: Container(),
      prefix: FButton.raw(
        onPress: null,
        child: Container(
          alignment: Alignment.center,
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: theme.avatarStyle.backgroundColor,
          ),
          clipBehavior: Clip.hardEdge,
          child: Text(getAcronym(document.name), style: theme.typography.xl6),
        ),
      ),
    );
  }

  @override
  Future<void> deleteDocument() async {
    final bool shouldDelete = await _confirmDelete() ?? false;

    if (!shouldDelete) return;

    final bool success = await document.delete();
    if (success && mounted) {
      Account.deleteAll(document);
      printWarn("Deleting Profile:${document.name} with id of: ${document.id}");
      Navigator.of(context).pop();
    }
  }

  @override
  void editDocument() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => ProfileForm(
          document: document,
          onSubmit: _onEdit,
        ),
      )
    );
    if (document.action == DocAction.update) setState(() => document = widget.document);
  }

  Future<bool> _onEdit() async {
    String msg = "Error writing the document to the database!";
    final bool success = await document.update();
    if (success) msg = "Successfully changed profile details";
    if (mounted) notify(context, msg);
    return success;
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
            onPress: () => Navigator.of(context).pop(false),
          ),
          FButton(
            style: FButtonStyle.destructive,
            label: const Text("Yes"),
            onPress: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
