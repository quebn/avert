import "package:flutter/material.dart";
import "package:avert/core.dart";
import "package:avert/core/components.dart";

// NOTE: should be a document in core.
class Company implements Document {
  Company({
    this.id = 0,
    this.name = "",
    int createdAt = 0,
  }): createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  @override
  int id;

  @override
  String name;

  @override
  DateTime createdAt;

  static String getTableQuery() => """
    CREATE TABLE companies(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      createdAt INTEGER NOT NULL
    )
  """;

  bool valuesNotValid() {
    return name.isEmpty;
  }

  @override
  Future<bool> update() async {
    if (valuesNotValid()) return false;
    Map<String, Object?> values = {
      "name": name,
    };
    printWarn("update with values of: ${values.toString()} of company with id of: $id!");
    int r = await App.database!.update("companies", values,
      where: "id = ?",
      whereArgs: [id],
    );
    return r == 1;
  }

  @override
  Future<bool> insert() async {
    if (id > 0) {
      printLog("Document is already inserted with id of '$id'");
      return false;
    }
    if (valuesNotValid()) return false;
    int now = DateTime.now().millisecondsSinceEpoch;
    Map<String, Object?> values = {
      "name": name,
      "createdAt": now,
    };
    printWarn("creating company with values of: ${values.toString()}");
    id = await App.database!.insert("companies", values);
    printWarn("company created with id of $id");
    return id != 0;
  }

  @override
  Future<bool> delete() async {
    int result =  await App.database!.delete("companies",
      where: "id = ?",
      whereArgs: [id],
    );
    return result == id;
  }
}

// TODO: Do something on the ff. in the future.
//  - show the fields from other modules like the default accounts of a company.
//  - validation.
class CompanyView extends StatefulWidget {
  const CompanyView({super.key,
    required this.company,
    this.onCreate,
    this.onSave,
    this.onSubmit,
    this.onDelete,
    this.onPop
  });

  final Company company;
  // NOTE: onDelete executes after the company is deleted in db.
  final VoidCallback? onCreate, onSave, onSubmit, onDelete, onPop;

  @override
  State<StatefulWidget> createState() => _CompanyViewState();
}

class _CompanyViewState extends State<CompanyView> implements DocumentView {

  final GlobalKey<FormState> key = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    'name': TextEditingController(),
  };

  bool isDirty = false;
  bool isNew = true;
  bool get formStatus => widget.company.id == 0;

  @override
  void initState() {
    super.initState();
    setFieldValues();
    controllers['name']!.addListener(onNameChange);
    isNew = formStatus;
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
    printWarn("Building Company Document");
    printLog("company.id = ${widget.company.id}");
    return AvertDocument(
      isDirty: isDirty,
      onPop: popDocument,
      yPadding: 16,
      xPadding: 16,
      actions: isNew ? null :  [
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
        onPressed: saveDocument,
        iconSize: 48,
        icon: Icon(Icons.save_rounded)
      ),
      formKey: key,
      title: isNew ? "New Company" : widget.company.name,
      widgetsBody: [
        AvertInput(
          yPadding: 8,
          name: "Company Name",
          controller: controllers['name']!,
          required: true,
        ),
      ],
    );
  }

  void setFieldValues() {
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
    String msg = "'${widget.company.name}' is already the default company!";
    if (App.company != widget.company) {
      App.company = widget.company;
      App.rememberCompany(widget.company.id);
      msg = "'${widget.company.name}' is now the Default Company!";
    }
    notifyUpdate("Default Company", msg);
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

  Future<bool?> notifyUpdate(String title, String msg) {
    // TODO: make title or anything in the dialog change color depending on the results.
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Center(
          heightFactor: 1,
          child: Text(msg),
        ),
        actions: [
          AvertButton(
            name: "Close",
            onPressed: () {
              Navigator.pop(context, true);
            }
          ),
        ]
      ),
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
    printLog("success bool: $success");

    if (success) {
      printWarn("inside success block");
      if (widget.onDelete != null) widget.onDelete!();
      const String title = "Company Deleted";
      final String msg = "'${widget.company.name}' is deleted successfully!";
      final bool shouldPop = await notifyUpdate(title, msg) ?? true;

      if (shouldPop && mounted) {
        Navigator.maybePop(context);
        if (widget.onPop != null) widget.onPop!();
      }
    }
  }

  @override
  Future<void> popDocument(bool didPop, Object? result) async {
    printLog("didPop: $didPop and result: $result");
    if (didPop) {
      printLog("did pop scope!");
      return;
    }

    final bool shouldPop = await confirmPop() ?? false;
    if (shouldPop && mounted) {
      Navigator.pop(context);
      if (widget.onPop != null) widget.onPop!();
    }
  }

  void onNameChange() => onFieldChange(<bool>() {
    return controllers['name']!.text != widget.company.name;
  });

  Future<bool?> confirmPop() {
    printWarn("showing pop confirmation dialog");
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are you sure?"),
          content: const Text("Are you sure you want to leave this page?"),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text("Stay"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () {
                Navigator.pop(context, true);
                //popDocument(context);
              },
              child: const Text("Leave"),
            ),
          ],
        );
      },
    );
  }

  @override
  Future<void> saveDocument() async {
    final bool isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    Company company = widget.company;
    company.name = controllers['name']!.value.text;
    String title = "Operation Failed!", msg = "Error writing the document to the database!";
    if (isNew) {
      bool success =  await company.insert();
      printLog("id after company: ${company.id}");
      if (widget.onCreate != null) widget.onCreate!();
      if (success) {
        title = "New Company Created!";
        msg = "Company '${company.name}' is successfully created!";
      }
    } else {
      bool success = await company.update();
      if (success){
        title = "Changes Saved!";
        msg = "Successfully changed company details";
      }
    }
    final bool shouldUpdate = await notifyUpdate(title, msg) ?? false;
    if (shouldUpdate) {
      setState(() {
          isNew = formStatus;
          isDirty = false;
      });
    }
  }
}
