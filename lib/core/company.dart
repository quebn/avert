import "package:flutter/material.dart";
import "package:acqua/core.dart";
import "package:acqua/core/components.dart";

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

  Future<bool> update() async {
    Map<String, Object?> values = {
      "name": name,
    };
    int r = await App.database!.update("companies", values,
      where: "id = ?",
      whereArgs: [id],
    );
    return r == 1;
  }

  Future<bool> save() async {
    if (id > 0) {
      // TODO: maybe have a prompt for this.
      printLog("Document is already inserted with id of '$id'");
      return false;
    }
    int now = DateTime.now().millisecondsSinceEpoch;
    Map<String, Object?> values = {
      "name": name,
      "createdAt": now,
    };
    id = await App.database!.insert("companies", values);
    return id != 0;
  }
  
  Future<int> deleteByID() async {
    return await App.database!.delete("companies",
      where: "id = ?",
      whereArgs: [id],
    );
  }
    
  @override
  Widget viewDocument() {
    // TODO: implement details
    throw UnimplementedError();
  }
}

// TODO: Do something on the ff. in the future.
//  - show the fields from other modules like the default accounts of a company.
//  - validation.
class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key, 
    required this.company,
    this.onCreate,
    this.onSave,
    this.onSubmit, 
    this.onDelete,
    this.onPop
  });

  final Company company;
  final VoidCallback? onCreate, onSave, onSubmit, onDelete, onPop;
  
  @override
  State<StatefulWidget> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {

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
    controllers['name']!.addListener(onNameChange);
    isNew = formStatus;
    if(!isNew) {
      setFieldValues();
    }
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
    return AcquaDocument(
      onPop: (didPop, result){ printLog("didPop:$didPop | value:${result.toString()}");},
      yPadding: 16,
      xPadding: 16,
      actions: isNew ? null :  [
        IconButton(
          color: Colors.red,
          onPressed: (){printLog("Delete Company");}, 
          icon: const Icon(Icons.delete_rounded,
          ),
        ),
        AcquaButton(
          name: "Set as Default",
          onPressed: (){printLog("Delete Company");}, 
        ),
      ],
      floationActionButton: isDirty ? IconButton.filled(
        onPressed: saveDocument,
        iconSize: 48,
        icon: Icon(Icons.save_rounded)
      ) : null,
      formKey: key,
      title: isNew ? "New Company" : widget.company.name,
      widgetsBody: [
        AcquaInput(
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
    setState(() {
      isDirty = isReallyDirty;
    });
  }

  void onNameChange() => onFieldChange(<bool>() {
    return controllers['name']!.text != widget.company.name;
  });

  // TODO: Implement document pop function.
  Future<bool?> _showBackDialog(BuildContext context) {
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
              child: const Text("Leave"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> saveDocument() async {
    if (!key.currentState!.validate()) {
      return;
    }
    // TEST: checks.
    // -- check if new or not. if new create the Company and get/make the message.
    // -- if not save the document.
    // -- display the message.
    String title = "Operation Failed!", msg = "Error writing the document to the database!";
    if (isNew) {
      bool success =  await widget.company.save();
      if (widget.onCreate != null) {
        widget.onCreate!();
      }
      if (success) {
        title = "New Company Created!";
        msg = "Company '${widget.company.name}' is successfully created!";
        setState(() => widget.company.name = controllers['name']!.value.text);
      }
    } else {
      bool success = await widget.company.update();
      if (success){
        title = "Changes Saved!";
        msg = "Successfully changed company details";
        widget.company.name = controllers['name']!.value.text;
      }
    }
    if (mounted) {
      notifyUpdate(context, title, msg);
    }
  }
  
  Future<void> notifyUpdate(BuildContext context, String title, String msg) {
    // TODO: make title or anything in the dialog change color depending on the results.
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Center(
          child: Text(msg),
        ),
        actions: [
          AcquaButton(
            name: "Close",
            onPressed: () => Navigator.pop(context),
          ),
        ]
      ),
    );
  }
}
