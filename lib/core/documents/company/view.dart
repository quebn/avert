import "package:avert/core/components/avert_button.dart";
import "package:avert/core/components/avert_document.dart";
import "package:avert/core/core.dart";

// TODO: Do something on the ff. in the future.
//  - show the fields from other modules like the default accounts of a company.
//  - validation.
//  - onSave should have parameters of the values of controllers in a dict.
class CompanyView extends StatefulWidget {
  const CompanyView({super.key,
    required this.company,
    this.onUpdate,
    this.onDelete,
    this.onPop,
    this.onSetDefault
  });

  final Company company;
  // NOTE: onDelete executes after the company is deleted in db.
  final void Function()? onUpdate, onDelete, onPop;
  final bool Function()? onSetDefault;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<CompanyView> implements DocumentView {

  final GlobalKey<FormState> key = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    'name': TextEditingController(),
  };

  bool isDirty = false;
  bool get formStatus => widget.company.id == 0;

  @override
  void initState() {
    super.initState();
    initDocumentFields();
    controllers['name']!.addListener(onNameChange);
  }

  @override
  void dispose() {
    controllers['name']!.removeListener(onNameChange);
    for (TextEditingController controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building Company Document");
    printInfo("company.id = ${widget.company.id}");
    return AvertDocument(
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
      isDirty: isDirty,
      onPop: widget.onPop,
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
      floationActionButton: !isDirty ? null :IconButton.filled(
        onPressed: updateDocument,
        iconSize: 48,
        icon: Icon(Icons.save_rounded)
      ),
      formKey: key,
      body: Container(),
    );
  }

  @override
  void initDocumentFields() {
    controllers['name']!.text = widget.company.name;
  }


  void onFieldChange(Function<bool>() isDirtyCallback) {
    final bool isReallyDirty = isDirtyCallback();
    if (isReallyDirty == isDirty) {
      return;
    }
    printTrack("Setting state of is dirty = $isReallyDirty");
    setState(() {
      isDirty = isReallyDirty;
    });
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
      // NOTE: snackbar notification should be handled inside the onDelete function.
      if (widget.onDelete != null) widget.onDelete!();
    }
  }

  void onNameChange() => onFieldChange(<bool>() {
    return controllers['name']!.text != widget.company.name;
  });

  @override
  void updateDocument() async {
    final bool isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());

    Company company = widget.company;
    company.name = controllers['name']!.value.text;

    String msg = "Error writing the document to the database!";

    bool success = await company.update();

    if (success) {
      if (widget.onUpdate != null) widget.onUpdate!();
      msg = "Successfully changed company details";
    }

    if (mounted) notifyUpdate(context, msg);

    setState(() {
      isDirty = false;
    });
  }
}
