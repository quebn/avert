import "package:avert/core/components/avert_button.dart";
import "package:avert/core/components/avert_document.dart";
import "package:avert/core/core.dart";
import "package:avert/core/components/avert_input.dart";
import "package:shared_preferences/shared_preferences.dart";

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

  Future<bool> valuesNotValid() async {
    bool hasDuplicates = await checkIfExist();
    return name.isEmpty || hasDuplicates;
  }

  Future<bool> checkIfExist() async {
    List<Map<String, Object?>> values = await Core.database!.query("companies",
      columns: ["id"],
      where: "name = ?",
      whereArgs: [name],
    );
    return values.isNotEmpty;
  }

  void remember() {
    SharedPreferencesAsync sp = SharedPreferencesAsync();
    sp.setInt("company_id", id);
  }

  @override
  Future<bool> update() async {
    if (await valuesNotValid() ) return false;
    Map<String, Object?> values = {
      "name": name,
    };
    printWarn("update with values of: ${values.toString()} of company with id of: $id!");
    int r = await Core.database!.update("companies", values,
      where: "id = ?",
      whereArgs: [id],
    );
    return r == 1;
  }

  @override
  Future<bool> insert() async {
    if (id > 0) {
      printLog("Document is should already be in database with id of '$id'");
      return false;
    }
    if (await valuesNotValid()) return false;
    int now = DateTime.now().millisecondsSinceEpoch;
    Map<String, Object?> values = {
      "name": name,
      "createdAt": now,
    };
    printWarn("creating company with values of: ${values.toString()}");
    id = await Core.database!.insert("companies", values);
    printWarn("company created with id of $id");
    return id != 0;
  }

  @override
  Future<bool> delete() async {
    int result =  await Core.database!.delete("companies",
      where: "id = ?",
      whereArgs: [id],
    );
    return result == id;
  }

  static Future<Company?> fetchDefault(Database db, SharedPreferencesWithCache sp) async {
    List<Map<String, Object?>> results = await db.query("companies",
      columns: ["id", "name", "createdAt",]
    );

    if (results.isEmpty) {
      return null;
    }

    printLog("${results.length} companies found with values of: ${results.toString()}");
    int companyID = sp.getInt("company_id") ?? 0;
    if (companyID == 0) {
      return Company(
        id: results[0]['id']! as int,
        name: results[0]['name']! as String,
        createdAt: results[0]['createdAt']! as int,
      );
    }

    for (Map<String, Object?> data in results) {
      if (companyID == data['id']) {
        return Company(
          id: data['id']! as int,
          name: data['name']! as String,
          createdAt: data['createdAt']! as int,
        );
      }
      break;
    }
    return null;
  }
}

// TODO: Do something on the ff. in the future.
//  - show the fields from other modules like the default accounts of a company.
//  - validation.
//  - onSave should have parameters of the values of controllers in a dict.
class CompanyView extends StatefulWidget {
  const CompanyView({super.key,
    required this.company,
    this.onCreate,
    this.onSave,
    this.onSubmit,
    this.onDelete,
    this.onPop,
    this.onSetDefault
  });

  final Company company;
  // NOTE: onDelete executes after the company is deleted in db.
  final void Function()? onCreate, onSave, onSubmit, onDelete, onPop;
  //final void Function(Map<String, Object?> values)? onSave;
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
    printSuccess("Building Company Document");
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
    widget.company.remember();
    if (widget.onSetDefault != null) {
      bool success = widget.onSetDefault!();
      if (success) {
        notifyUpdate("'${widget.company.name}' is now the Default Company!");
      }
    }
    notifyUpdate("'${widget.company.name}' is already the default company!");
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

  void notifyUpdate(String msg) {
    final SnackBar snackBar = SnackBar(
      showCloseIcon: true,
      content: Center(
        child: Text(msg),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

    if (success && mounted) {
      printWarn("inside success block");
      if (widget.onDelete != null) widget.onDelete!();
      Navigator.maybePop(context);
      // TODO: add a snackbar notification that this document is deleted.
    }
  }

  @override
  Future<void> popDocument(bool didPop, Object? result) async {
    printLog("didPop: $didPop and result: $result");
    if (didPop) {
      if (widget.onPop != null && !isDirty) widget.onPop!();
      printLog("did pop scope!");
      return;
    }

    final bool shouldPop = await confirmPop() ?? false;
    if (shouldPop && mounted) {
      Navigator.pop(context);
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

    FocusScope.of(context).requestFocus(FocusNode());

    Company company = widget.company;
    company.name = controllers['name']!.value.text;
    String msg = "Error writing the document to the database!";
    if (isNew) {
      bool success =  await company.insert();
      printLog("id after company: ${company.id}");
      if (widget.onCreate != null) widget.onCreate!();
      if (success) {
        msg = "Company '${company.name}' is successfully created!";
      }
    } else {
      bool success = await company.update();
      if (success){
        if (widget.onSave != null) widget.onSave!();
        msg = "Successfully changed company details";
      }
    }

    notifyUpdate(msg);
    setState(() {
      isDirty = false;
      isNew = formStatus;
    });
  }
}
