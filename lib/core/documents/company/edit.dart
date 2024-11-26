import "package:avert/core/components/avert_button.dart";
import "package:avert/core/components/avert_document.dart";
import "package:avert/core/core.dart";

class CompanyEditForm extends StatefulWidget {
  const CompanyEditForm({super.key,
    required this.company,
    this.onUpdate,
    this.onPop,
  });

  final Company company;
  final void Function()? onUpdate, onPop;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<CompanyEditForm> implements DocumentEdit {

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
    printTrack("Building Company Document View");
    printInfo("company.id = ${widget.company.id}");
    // IMPORTANT: Should be CompanyDocumentView
    return AvertDocumentForm(
      name: widget.company.name,
      widgetsBody: [],
      //isDirty: isDirty,
      onPop: widget.onPop,
      floatingActionButton:IconButton.filled(
        onPressed: updateDocument,
        iconSize: 48,
        icon: Icon(Icons.save_rounded)
      ),
      //formKey: key,
    );
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

  @override
  void initDocumentFields() {
    controllers['name']!.text = widget.company.name;
  }
}
