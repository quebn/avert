import "package:avert/core/components/avert_document.dart";
import "package:avert/core/components/avert_button.dart";
import "package:avert/core/core.dart";
import "package:crypto/crypto.dart";
import "package:shared_preferences/shared_preferences.dart";

class User implements Document {
  User({
    this.id = 0,
    this.name = "",
    int createdAt = 0,
  }): createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  User.fromQuery({
    required Object id,
    required Object name,
    required Object createdAt,
  }):
    id = id as int,
    name = name as String,
    createdAt =  DateTime.fromMillisecondsSinceEpoch(createdAt as int)
  ;


  @override
  int id;

  @override
  String name;

  @override
  DateTime createdAt;

  String _password = "";
  bool get isAdmin => id == 1;

  set password(Digest value) => _password = value.toString();

  static String getTableQuery() => """
    CREATE TABLE users(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      password TEXT NOT NULL,
      createdAt INTEGER NOT NULL
    )
  """;

  Future<bool> valuesNotValid() async {
    List<Map<String, Object?>> values = await Core.database!.query("users",
      columns: ["id"],
      where: "name = ?",
      whereArgs: [name],
    );
    return name.isEmpty || values.isNotEmpty;
  }

  Future<bool> nameExist() async {
    List<Map<String, Object?>> results = await Core.database!.query("users",
      where:"name = ?",
      whereArgs: [name],
    );
    return results.isNotEmpty;
  }

  @override
  Future<bool> delete() async {
    int result =  await Core.database!.delete("users",
      where: "id = ?",
      whereArgs: [id],
    );
    return result == id;
  }

  @override
  Future<bool> insert() async {
    if (_password.isEmpty) return false;
    var values = {
      "name"      : name,
      "password"  : _password,
      "createdAt" : DateTime.now().millisecondsSinceEpoch,
    };
    printDebug("Inserting to users table values: ${values.toString()}", level: LogLevel.warn);
    bool success = await Core.database!.insert("users", values) > 0 ;
    if (success) _password = "";
    return success;
  }

  @override
  Future<bool> update() async {
    if (await valuesNotValid() ) return false;
    Map<String, Object?> values = {
      "name": name,
    };
    printWarn("update with values of: ${values.toString()} on user with id of: $id!");
    int r = await Core.database!.update("users", values,
      where: "id = ?",
      whereArgs: [id],
    );
    return r == 1;
  }

  // TODO: add some params later for specific checking.
  static Future<bool> checkUsers() async {
    List<Map<String, Object?>> result = await Core.database!.query("users",
      columns: ["id"],
    );
    return result.isNotEmpty;
  }

  void remember() {
    final SharedPreferencesAsync sp = SharedPreferencesAsync();
    sp.setInt("user_id", id);
    printInfo("saving user: '$name's ID in cache with value of:[$id]!");
  }

  void forget() {
    final SharedPreferencesAsync sp = SharedPreferencesAsync();
    sp.remove("user_id");
  }
}

class UserView extends StatefulWidget  {
  const UserView({super.key,
    required this.user,
    this.onSave,
    this.onDelete,
    this.onPop,
    this.onSetDefault
  });

  final User user;
  // NOTE: onDelete executes after the company is deleted in db.
  final void Function()? onSave, onDelete, onPop;
  //final void Function(Map<String, Object?> values)? onSave;
  final bool Function()? onSetDefault;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<UserView> implements DocumentView {
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    'name': TextEditingController(),
  };
  bool isDirty = false;

  Future<bool?> confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete User?"),
          content: Text(
            "Are you sure you want to delete '${widget.user.name}'? deleting this user will direct you to Login Screen."
          ),
          actions: <Widget>[
            AvertButton(
              bgColor: Colors.red,
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
    return controllers['name']!.text != widget.user.name;
  });

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
  Future<void> deleteDocument() async {
    final bool shouldDelete = await confirmDelete() ?? false;

    if (!shouldDelete) {
      return;
    }

    final bool success = await widget.user.delete();
    printWarn("Deleting user:${widget.user.name} with id of: ${widget.user.id}");

    if (success && mounted) {
      printSuccess("User Deleted!");
      Navigator.maybePop(context);
      // NOTE: snackbar notification should be handled inside the onDelete function.
      if (widget.onDelete != null) widget.onDelete!();
    } else {
      printInfo("User not Deleted!");
    }
  }

  @override
  Future<void> popDocument(bool didPop, Object? value) async {
    if (didPop) {
      if (widget.onPop != null && !isDirty) widget.onPop!();
      return;
    }

    final bool shouldPop = await confirmPop(context) ?? false;
    if (shouldPop && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void saveDocument() async {
    final bool isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    FocusScope.of(context).requestFocus(FocusNode());

    User user = widget.user;
    user.name = controllers['name']!.value.text;
    String msg = "Error writing the document to the database!";

    bool success = await user.update();
    if (success){
      if (widget.onSave != null) widget.onSave!();
      msg = "Successfully changed company details";
    }

    if (mounted) notifyUpdate(context, msg);
    setState(() {
      isDirty = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return AvertDocument(
      isDirty: isDirty,
      bgColor: Colors.black,
      onPop: popDocument,
      widgetsBody: [
        // IMPORTANT: make proper profile page look.
        // Card
        profileHeader(),
        profileBody(),
      ],
      floationActionButton: !isDirty ? null : IconButton.filled(
        onPressed: saveDocument,
        iconSize: 48,
        icon: Icon(Icons.save_rounded)
      ),
    );
  }

  @override
  void initDocumentFields() {
    controllers['name']!.text = widget.user.name;
  }

  Widget profileHeader() {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 72),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              shadowColor: Colors.black,
              child: Padding(
                padding: EdgeInsets.only(top: 80, bottom: 16),
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // TODO: add indicator for when if user is admin. (maybe a crown icon)
                    // user is admin if id is 1.
                    Center(
                      child: TextButton(
                        onPressed: () {},//promptEditField(),
                        child: Text(widget.user.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // NOTE: add header widgets here.
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 72,
            ),
            onPressed: () => printInfo("Pressed Profile Pic"),
          ),
        ]
      ),
    );
  }

  Widget profileBody() {
    return Container(
      margin: EdgeInsets.only(top: 24),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadowColor: Colors.black,
        child: Column(
          children: [
            // TODO: add indicator for when if user is admin. (maybe a crown icon)
            // user is admin if id is 1.
            dangerSection(),
            // NOTE: add header widgets here.
          ],
        ),
      ),
    );

  }

  Widget dangerSection() => Container(
    padding:EdgeInsets.symmetric(vertical: 16),
    child: Column(
      children: [
        const Padding(
          padding:EdgeInsets.only(bottom: 8),
          child: Center(
            child: Text("Danger Zone",
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        AvertButton(
          bgColor: Colors.red,
          name: "Delete User",
          onPressed: deleteDocument,
          ),
      ]
    ),
  );
}
