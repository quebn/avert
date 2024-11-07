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
  });

  final Company company;
  final VoidCallback? onCreate, onSave, onSubmit, onDelete;
  
  @override
  State<StatefulWidget> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {

  final GlobalKey<FormState> key = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    'name': TextEditingController(),
  };

  bool isNew = true;
  bool get formStatus => widget.company.id == 0;

  @override
  void initState() {
    super.initState();
    isNew = formStatus;
    controllers['name']!.text = widget.company.name;
  }

  @override
  void dispose() {
    for (TextEditingController controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (isNew) {
      return AcquaDocument(
        formKey: key,
        title: "New Company",
        widgetsBody: [
          AcquaInput(
            xPadding: 24,
            name: "Company Name", 
            controller: controllers['name']!,
            required: true,
          ),
        ],
        widgetsFooter: [
          AcquaButton(
            name: "Create Company", 
            onPressed: createCompany,
            yPadding: 16,
          ),
        ],
      );
    }
    return AcquaDocument(
      formKey: key,
      title: widget.company.name,
      widgetsBody: [
        AcquaInput(
          xPadding: 24,
          name: "Company Name", 
          controller: controllers['name']!,
          required: true,
        ),
      ],
      widgetsFooter: [
        AcquaButton(
          name: "Save Changes", 
          onPressed: saveCompany,
          yPadding: 16,
        ),
      ],
    );
  }

  Future<void> createCompany() async {
    if (!key.currentState!.validate()) {
      return;
    }
    widget.company.name = controllers['name']!.value.text;
    printLog("Pressed Create Company with value of: ${ widget.company.name }");
    bool success =  await widget.company.save();

    if (widget.onCreate != null) {
      widget.onCreate!();
    }

    if (success) {
      notifyCreation();
    }
    // showPopup depending on the result of the insertion.
  }

  Future<void> notifyCreation() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Success"),
        content: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            """
              New company '${widget.company.name}' is create successfully!\n
              Would you like to set it as the current Company?
            """,
          ),
        ),
        actions: [
          AcquaButton(
            name: "No",
            onPressed: (){
              Navigator.pop(context);
              printLog("Pressed No");
              setState(() => isNew = formStatus);
            },
          ),
          AcquaButton(
            name: "Yes",
            onPressed: (){
              if (App.company != widget.company) {
                printLog("Setting as the current company in with the popUp!", level:LogLevel.warn);
                App.company = widget.company;
              }
              App.rememberCompany(widget.company.id);
              Navigator.pop(context);
              setState(() => isNew = formStatus);
            },
          ),
        ]
      ),
    );
  }

  Future<void> saveCompany() async {
    if (!key.currentState!.validate()) {
      return;
    }
    widget.company.name = controllers['name']!.value.text;
    printLog("Pressed Create Company with value of: ${ widget.company.name }");
    bool success = await widget.company.update();
    if (success){
      
    }
    printAssert(App.company != null, "App Company is null where it shouldnt!");
    // showPopup for confirmation of creation.
    throw UnimplementedError();
  }
  
  Future<void> notifyUpdate() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Success"),
        content: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            """
              Company '${widget.company.name}' have been successfully updated!
            """,
          ),
        ),
        actions: [
          AcquaButton(
            name: "Close",
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ]
      ),
    );
  }
}
