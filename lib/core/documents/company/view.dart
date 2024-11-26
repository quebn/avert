import "package:avert/core/components/avert_button.dart";
import "package:avert/core/components/avert_document.dart";
import "package:avert/core/core.dart";

import "form.dart";

// TODO: Do something on the ff. in the future.
//  - show the fields from other modules like the default accounts of a company.
//  - validation.
//  - onSave should have parameters of the values of controllers in a dict.
class CompanyView extends StatefulWidget {
  const CompanyView({super.key,
    required this.company,
    this.onUpdate,
    this.onDelete,
    this.onSetDefault
  });

  final Company company;
  final void Function()? onUpdate, onDelete;// onPop;
  final bool Function()? onSetDefault;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<CompanyView> implements DocumentView {

  @override
  Widget build(BuildContext context) {
    printTrack("Building Company Document View");
    printInfo("company.id = ${widget.company.id}");
    return AvertDocumentView(
      name: widget.company.name,
      image: IconButton(
        icon: CircleAvatar(
          radius: 50,
          child: Text(widget.company.name[0].toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 50,
            ),
          ),
        ),
        onPressed: () => printInfo("Pressed Profile Pic"),
      ),
      titleChildren: [
        Text(widget.company.name,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text("Current Company",
          style: TextStyle(
            fontSize: 18,
          ),
        ),

      ],
      //isDirty: isDirty,
      actions: [
        TextButton(
          onPressed: setAsDefault,
          child: const Text("Set as Default",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: IconButton(
            iconSize: 32,
            onPressed: deleteDocument,
            icon: const Icon(Icons.delete_rounded,
            ),
          ),
        ),
      ],
      floatingActionButton: IconButton.filled(
        onPressed: editDocument,
        iconSize: 48,
        icon: Icon(Icons.edit_rounded,
        )
      ),
      //formKey: key,
      body: Container(),
    );
  }

  void editDocument() {
    Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) => CompanyForm(
        company: widget.company,
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
    widget.company.remember();
    if (widget.onSetDefault != null) {
      bool success = widget.onSetDefault!();
      if (success) {
        notifyUpdate(context, "'${widget.company.name}' is now the Default Company!");
      }
    }
    notifyUpdate(context, "'${widget.company.name}' is already the default company!");
  }

  Future<bool?> confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete '${widget.company.name}'?"),
          content: const Text("Are you sure you want to delete this Company?"),
          actions: <Widget>[
            AvertButton(
              name: "Yes",
              onPressed: () {
                Navigator.pop(context, true);
              }
            ),
            AvertButton(
              name: "No",
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Future<void> deleteDocument() async {
    final bool shouldDelete = await confirmDelete() ?? false;

    if (!shouldDelete) {
      return;
    }

    final bool success = await widget.company.delete();
    printWarn("Deleting Company:${widget.company.name} with id of: ${widget.company.id}");

    if (success && mounted) {
      Navigator.maybePop(context);
      notifyUpdate(context, "Company '${widget.company.name}' successfully deleted!");
      if (widget.onDelete != null) widget.onDelete!();
    }
  }
}
