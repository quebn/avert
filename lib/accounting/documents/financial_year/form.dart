import "package:avert/accounting/documents/financial_year/view.dart";
import "package:avert/core/components/avert_button.dart";
import "package:avert/core/components/avert_document.dart";
import "package:avert/core/components/avert_input.dart";
import "package:avert/core/core.dart";

import "document.dart";

class FinancialYearForm extends StatefulWidget {
  const FinancialYearForm({super.key,
    required this.document,
    this.onInsert,
    this.onUpdate,
  });

  const FinancialYearForm.conm({super.key,
    required this.document,
    this.onInsert,
    this.onUpdate,
  });

  final FinancialYear document;
  final void Function()? onInsert, onUpdate;

  @override
  State<StatefulWidget> createState() => _FormState();
}

class _FormState extends State<FinancialYearForm> implements DocumentForm {

  @override
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  final Map<String, TextEditingController> controllers = {
    'name': TextEditingController(),
    'start': TextEditingController(),
    'end': TextEditingController(),
  };

  @override
  bool isDirty = false;

  @override
  String? errMsg;

  @override
  void initState() {
    initDocumentFields();
    controllers['name']!.addListener(onNameChange);
    super.initState();
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
    printTrack("Building Financial Year Document Form");
    printInfo("Financial Year ID = ${widget.document.id}");
    return AvertDocumentForm(
      xPadding: 16,
      yPadding: 16,
      title: "${isNew(widget.document) ? "New" : "Edit"} Financial Year",
      widgetsBody: [
        AvertInput(
          label: "Name",
          controller: controllers['name']!,
          required: true,
          forceErrMsg: errMsg,
        ),
        AvertButton(
          yPadding: 16,
          xMargin: 8,
          yMargin: 8,
          onPressed: () {},
          name: "Start Date",
        ),

      ],
      isDirty: isDirty,
      floatingActionButton: !isDirty ? null :IconButton.filled(
        onPressed: isNew(widget.document) ? insertDocument : updateDocument,
        iconSize: 48,
        icon: Icon(Icons.save_rounded)
      ),
      formKey: key,
    );
  }

  @override
  void initDocumentFields() {
    controllers['name']!.text = widget.document.name;
    // TODO: controllers for:
    // - Start
    // - End
    // - Companies
  }

  @override
  Future<void> insertDocument() async {
    final bool isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    FocusScope.of(context).requestFocus(FocusNode());

    FinancialYear document = widget.document;
    document.name = controllers['name']!.value.text;


    bool success =  await document.insert();

    String msg = "Error writing the document to the database!";

    if (success) {
      if (widget.onInsert != null) widget.onInsert!();
      msg = "AccountingPeriod '${document.name}' successfully created!";

      if (mounted) {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(
          builder: (BuildContext context) {
            return FinancialYearView(
              document: widget.document,
              onUpdate: widget.onUpdate,
            );
          }
        ));
        notifyUpdate(context, msg);
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
    // TODO: do for add controllers.
    // EX.
    // widget.document.name = controllers['name']!.value.text;

    String msg = "Error writing the document to the database!";

    // TODO: Maybe this function should return false when no changes are made.
    bool success = await widget.document.update();

    if (success) {
      if (widget.onUpdate != null) widget.onUpdate!();
      msg = "Successfully changed company details";
    }

    if (mounted) notifyUpdate(context, msg);

    setState(() {
      isDirty = false;
    });
  }

  void onNameChange() => onFieldChange(<bool>() {
    return controllers['name']!.text != widget.document.name;
  });

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
}
