import "package:avert/core/components/avert_document.dart";
import "package:avert/core/core.dart";
import "package:avert/core/utils/ui.dart";
import "package:forui/forui.dart";

import "form.dart";

class CompanyView extends StatefulWidget {
  const CompanyView({super.key,
    required this.document,
    this.onUpdate,
    this.onDelete,
    this.onSetDefault,
    this.isDefault = false,
  });

  final bool isDefault;
  final Company document;
  final void Function()? onUpdate, onDelete;// onPop;
  final bool Function()? onSetDefault;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<CompanyView> with SingleTickerProviderStateMixin implements DocumentView  {
  late final FPopoverController _controller = FPopoverController(vsync: this);

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building Company Document View");
    printInfo("company.id = ${widget.document.id}");
    return AvertDocumentView(
      controller: _controller,
      name: "Company",
      title: widget.document.name,
      subtitle: widget.isDefault ? "Current Company" : "Company",
      menuActions: [
        FTileGroup(
          children: [
            FTile(
              prefixIcon: FIcon(FAssets.icons.building),
              title: const Text("Set as Default"),
              onPress: setAsDefault,
            ),
          ],
        ),
      ],
      onEdit: editDocument,
      onDelete: deleteDocument,
      content: Container(),
    );
  }

  void editDocument() {
    Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) => CompanyForm(
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

  void setAsDefault() {
    widget.document.remember();
    if (widget.onSetDefault != null) {
      bool success = widget.onSetDefault!();
      if (success) {
        notify(context, "'${widget.document.name}' is now the Default Company!");
      }
    }
    notify(context, "'${widget.document.name}' is already the default company!");
  }

  Future<bool?> confirmDelete() {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (BuildContext context) => FDialog(
        direction: Axis.horizontal,
        title: Text("Delete '${widget.document.name}'?"),
        body: const Text("Are you sure you want to delete this Company?"),
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
      printWarn("Deleting Company:${widget.document.name} with id of: ${widget.document.id}");

      if (success && mounted) {
        Navigator.maybePop(context);
        if (widget.onDelete != null) widget.onDelete!();
        notify(context, "Company '${widget.document.name}' successfully deleted!");
      }
    }
  }
}
