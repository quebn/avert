//import "package:avert/core/components/avert_button.dart";
//import "package:avert/core/components/avert_input.dart";
import "package:avert/core/components/avert_document.dart";
import "package:avert/core/components/avert_input.dart";
import "package:avert/core/core.dart";
import "package:avert/core/utils/ui.dart";
import "view.dart";

class CompanyForm extends StatefulWidget {
  const CompanyForm({super.key,
    required this.document,
    this.onInsert,
    this.onUpdate,
    this.onSetDefault,
  });

  final Company document;
  final void Function()? onInsert, onUpdate;
  final bool Function()? onSetDefault;

  @override
  State<StatefulWidget> createState() => _NewState();
}

class _NewState extends State<CompanyForm> implements DocumentForm {
  @override
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  final Map<String, TextEditingController> controllers = {
    'name': TextEditingController(),
  };

  @override
  bool isDirty = false;

  @override
  String? errMsg;

  @override
  void dispose() {
    for (TextEditingController controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building CompanyDocumentForm");
    return AvertDocumentForm(
      formKey: key,
      title: Text("${isNew(widget.document) ? "New" : "Edit"} Company",),
      contents: [
        AvertInput.text(
          label: "Name",
          hint: "Ex. Acme Inc.",
          controller: controllers['name']!,
          required: true,
          forceErrMsg: errMsg,
          initialValue: widget.document.name,
          onChange: (value) => onValueChange((){
            return value != widget.document.name;
          }),
        ),
      ],
      isDirty: isDirty,
      floatingActionButton: !isDirty ? null :IconButton.filled(
        onPressed: isNew(widget.document) ? insertDocument : updateDocument,
        iconSize: 48,
        icon: Icon(Icons.save_rounded)
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  void onValueChange(bool Function() isDirtyCallback) {
    final bool isReallyDirty = isDirtyCallback();
    if (isReallyDirty == isDirty) {
      return;
    }
    printTrack("Setting state of is dirty = $isReallyDirty");
    setState(() {
      isDirty = isReallyDirty;
    });
  }

  @override
  Future<void> insertDocument() async {
    final bool isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    FocusScope.of(context).requestFocus(FocusNode());

    Company company = widget.document;
    company.name = controllers['name']!.value.text;


    bool success =  await company.insert();

    String msg = "Error writing the document to the database!";

    if (success) {
      if (widget.onInsert != null) widget.onInsert!();
      msg = "Company '${company.name}' successfully created!";

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return CompanyView(
              document: widget.document,
              onUpdate: widget.onUpdate,
            );
          }
        ));
        notify(context, msg);
      }
    }
  }

  @override
  void updateDocument() async {
    final bool isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());

    widget.document.name = controllers['name']!.value.text;

    String msg = "Error writing the document to the database!";

    // TODO: Maybe this function should return false when no changes are made.
    bool success = await widget.document.update();

    if (success) {
      if (widget.onUpdate != null) widget.onUpdate!();
      msg = "Successfully changed company details";
    }

    if (mounted) notify(context, msg);

    setState(() {
      isDirty = false;
    });
  }
}
