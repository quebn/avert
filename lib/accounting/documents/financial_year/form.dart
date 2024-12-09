import "package:avert/accounting/documents/financial_year/view.dart";
import "package:avert/core/components/avert_document.dart";
import "package:avert/core/components/avert_dropdown.dart";
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

  late String startDate, endDate;

  @override
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  final Map<String, TextEditingController> controllers = {
    'name': TextEditingController(),
    'type': TextEditingController(),
    'start_date': TextEditingController(),
    'end_date': TextEditingController(),
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
    printTrack("Building Financial Year Document Form");
    printInfo("Financial Year ID = ${widget.document.id}");
    return AvertDocumentForm(
      xPadding: 16,
      yPadding: 16,
      title: "${isNew(widget.document) ? "New" : "Edit"} Financial Year",
      widgetsBody: [
        Row(
          children: [
            AvertInput.text(
              label: "Name",
              placeholder: "Ex. 2024",
              controller: controllers['name']!,
              required: true,
              forceErrMsg: errMsg,
              expand: true,
              listener: onNameChange,
              initialValue: widget.document.name,
            ),
            AvertDropdown(
              label: "Type",
              options: getTypeOptions(),
              controller: controllers['type']!,
              listener: onTypeChange,
              initialSelection: widget.document.type,
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AvertInput.date(
              label: "Year Start",
              controller: controllers['start_date']!,
              required: true,
              forceErrMsg: errMsg,
              expand: true,
              listener: onStartDateChange,
              initialValue: getDate(widget.document.start),
            ),
            AvertInput.text(
              label: "Year End",
              placeholder: "YYYY-MM-DD",
              controller: controllers['end_date']!,
              required: true,
              readOnly: true,
              forceErrMsg: errMsg,
              expand: true,
              initialValue: getDate(widget.document.end),
            ),
          ],
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
  Future<void> insertDocument() async {
    throw UnimplementedError();
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
    throw UnimplementedError();
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

  void onNameChange() => onFieldChange(() {
    return controllers['name']!.text != widget.document.name;
  });

  void onStartDateChange() => onFieldChange(() {
    bool hasChange = controllers["start_date"]!.text != getDate(widget.document.start);
    if (hasChange) {
      String newStartDate = controllers["start_date"]!.text;
      calculateEndDate(newStartDate);
    }
    return hasChange;
  });

  void onTypeChange() => onFieldChange(() {
    printInfo("DropDown Value ${controllers["type"]!.text}");
    return controllers["type"]!.text != widget.document.type.label;
  });

  void onFieldChange(bool Function() isDirtyCallback) {
    final bool isReallyDirty = isDirtyCallback();
    if (isReallyDirty == isDirty) {
      return;
    }
    printTrack("Setting state of is dirty = $isReallyDirty");
    setState(() {
      isDirty = isReallyDirty;
    });
  }

  void calculateEndDate(String? startDate) {
    if (startDate == null) return;
    printInfo("Start Date: $startDate");
    String endDate = getLastDayString(startDate);
    printInfo("End Date: $endDate");
    controllers['end_date']!.text = endDate;
  }

  List<DropdownMenuEntry<FinancialYearType>> getTypeOptions() {
    return FinancialYearType.values.map<DropdownMenuEntry<FinancialYearType>>(
      (FinancialYearType type) {
        return DropdownMenuEntry<FinancialYearType>(
          value: type,
          label: type.label,
        );
      }
    ).toList();
  }
}
