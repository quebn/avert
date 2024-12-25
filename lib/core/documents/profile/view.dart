import "package:avert/core/components/avert_document.dart";
import "package:avert/core/core.dart";
import "package:forui/forui.dart";

import "form.dart";

class ProfileView extends StatefulWidget {
  const ProfileView({super.key,
    required this.document,
    required this.profile,
    this.onUpdate,
    this.onDelete,
    this.isDefault = false,
  });

  final bool isDefault;
  final Profile document, profile;
  final void Function()? onUpdate, onDelete;// onPop;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<ProfileView> with SingleTickerProviderStateMixin implements DocumentView  {
  late final FPopoverController _controller = FPopoverController(vsync: this);

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building Profile Document View");
    printInfo("profile.id = ${widget.document.id}");
    return AvertDocumentView(
      controller: _controller,
      name: "Profile",
      title: widget.document.name,
      subtitle: widget.isDefault ? "Current Profile" : "Profile",
      onEdit: editDocument,
      onDelete: deleteDocument,
      content: Container(),
    );
  }

  void editDocument() {
    Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) => ProfileForm(
        document: widget.document,
        onUpdate: () {
          // HACK: currently alway rebuilds the whole Widget.
          // TODO: maybe use map for the args to assign for setUpdate?
          setState(() {});
          if (widget.onUpdate != null) {
            widget.onUpdate!();
          }
        },
      ),
    ));
  }

  Future<bool?> confirmDelete() {
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

  @override
  Future<void> deleteDocument() async {
    final bool shouldDelete = await confirmDelete() ?? false;

    if (shouldDelete) {
      final bool success = await widget.document.delete();

      if (success && mounted) {
        printWarn("Deleting Profile:${widget.document.name} with id of: ${widget.document.id}");
        Navigator.maybePop(context);
        if (widget.onDelete != null) widget.onDelete!();
      }
    }
  }
}
