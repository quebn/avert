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
  late final FPopoverController controller = FPopoverController(vsync: this);

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building Company Document View");
    printInfo("company.id = ${widget.document.id}");
    return AvertDocumentView(
      controller: controller,
      name: "Company",
      title: widget.document.name,
      subtitle: widget.isDefault ? "Current Company" : "Company",
      menuActions: [
        FTileGroup(
          children: [
            FTile(
              prefixIcon: FIcon(FAssets.icons.building),
              title: const Text("Set as Default"),
              onPress: () {},
            ),
          ],
        ),
      ],
      onEdit: editDocument,
      content: Container(),
    );
  }

  void editDocument() {
    Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) => CompanyForm(
        document: widget.document,
        // HACK: currently alway rebuilds the whole Widget.
        // TODO: maybe use map for the args to assign for setUpdate?
        onUpdate: () {
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
    throw UnimplementedError();
    //return showDialog<bool>(
    //  context: context,
    //  builder: (BuildContext context) {
    //    return AlertDialog(
    //      title: Text("Delete '${widget.document.name}'?"),
    //      content: const Text("Are you sure you want to delete this Company?"),
    //      actions: <Widget>[
    //        AvertButton(
    //          name: "Yes",
    //          onPressed: () {
    //            Navigator.pop(context, true);
    //          }
    //        ),
    //        AvertButton(
    //          name: "No",
    //          onPressed: () {
    //            Navigator.pop(context, false);
    //          },
    //        ),
    //      ],
    //    );
    //  },
    //);
  }

  @override
  Future<void> deleteDocument() async {
    final bool shouldDelete = await confirmDelete() ?? false;

    if (!shouldDelete) {
      return;
    }

    final bool success = await widget.document.delete();
    printWarn("Deleting Company:${widget.document.name} with id of: ${widget.document.id}");

    if (success && mounted) {
      Navigator.maybePop(context);
      notify(context, "Company '${widget.document.name}' successfully deleted!");
      if (widget.onDelete != null) widget.onDelete!();
    }
  }
}
