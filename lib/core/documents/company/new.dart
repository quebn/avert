import "package:avert/core/components/avert_button.dart";
import "package:avert/core/components/avert_document.dart";
import "package:avert/core/components/avert_input.dart";
import "package:avert/core/core.dart";
import "view.dart";

class CompanyNew extends StatefulWidget {
  const CompanyNew({super.key,
    required this.company,
    this.onInsert,
    this.onPop,
    this.onSetDefault,
  });

  final Company company;
  final void Function()? onInsert, onPop;
  final bool Function()? onSetDefault;

  @override
  State<StatefulWidget> createState() => _NewState();
}

class _NewState extends State<CompanyNew> implements DocumentNew {

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
    return AvertDocumentNew(
      name: "Company",
      widgetsBody: [
        AvertInput(
          name: "Name",
          controller: controllers['name']!,
        )
      ],
      isDirty: isDirty,
      floationActionButton: !isDirty ? null :IconButton.filled(
        onPressed: insertDocument,
        iconSize: 48,
        icon: Icon(Icons.save_rounded)
      ),
      formKey: key,
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
  Future<void> insertDocument() async {
    final bool isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    FocusScope.of(context).requestFocus(FocusNode());

    Company company = widget.company;
    company.name = controllers['name']!.value.text;


    bool success =  await company.insert();

    String msg = "Error writing the document to the database!";

    if (success) {
      if (widget.onInsert != null) widget.onInsert!();
      msg = "Company '${company.name}' is successfully created!";

      if (mounted) {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(
          builder: (BuildContext context) {
            return CompanyView(
              company: widget.company,
              onPop: widget.onPop,
            );
          }
        ));
        notifyUpdate(context, msg);
      }
    }
  }
}
