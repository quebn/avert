import "package:avert/core/components/avert_input_prompt.dart";
import "package:avert/core/core.dart";
import "package:avert/core/components/avert_document.dart";
import "package:avert/core/components/avert_button.dart";

class UserView extends StatefulWidget  {
  const UserView({super.key,
    required this.user,
    this.onSave,
    this.onDelete,
    this.onPop,
    this.onSetDefault,
    this.viewOnly = true,
  });

  final User user;
  // NOTE: onDelete executes after the company is deleted in db.
  final void Function()? onSave, onDelete, onPop;
  final bool Function()? onSetDefault;
  final bool viewOnly;

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
    printInfo("Pressed save user.");
    final bool isValid = key.currentState?.validate() ?? false;
    if (!isValid) {
      printInfo("not Valid apparently");
      return;
    }

    widget.user.name = controllers['name']!.value.text;
    String msg = "Error writing the document to the database!";

    bool success = await widget.user.update();
    if (success){
      if (widget.onSave != null) widget.onSave!();
      msg = "Successfully changed user details";
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
    printTrack("Building UserView");
    return AvertDocument(
      formKey: key,
      isDirty: isDirty,
      bgColor: Colors.black,
      onPop: popDocument,
      widgetsBody: [
        // TODO: edit user.name
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
                  children: [
                    // NOTE: probably not a great impl but is cool.
                    AvertInputPrompt(
                      controller: controllers['name']!,
                      text: widget.user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      onValueChange: onNameChange,
                      viewOnly: widget.viewOnly,
                    ),
                    // TODO: add indicator for when if user is admin. (maybe a crown icon)
                    // user is admin if id is 1.
                    // probably overdoing this thing.
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
            dangerSection(),
          ],
        ),
      ),
    );
  }

  Widget dangerSection() => Container(
    padding:EdgeInsets.symmetric(vertical: 16),
    child: widget.viewOnly ? Container() : Column(
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

class UserListView extends StatefulWidget {
  const UserListView({super.key, required this.user});

  final User user;
  @override
  State<StatefulWidget> createState() => _ListViewState();
}

class _ListViewState extends State<UserListView> {
  List<User> users = [];

  @override
  Widget build(BuildContext context) {
    printTrack("Building User List View");
    if (users.isEmpty) {
      users.add(widget.user);
      fetchOtherUsers();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          return UserListTile(
            user: users[index],
          );
       },
      ),
    );
  }

  Future<void> fetchOtherUsers() async {
    List<Map<String, Object?>> results = await Core.database!.query("users",
      columns: ["id", "name", "createdAt"],
      where: "id != ?",
      whereArgs: [widget.user.id]
    );
    List<User> localUser = users;
    for (Map<String, Object?> result in results ) {
      localUser.add(User.fromQuery(
        id: result["id"]!,
        name: result["name"]!,
        createdAt: result["createdAt"]!,
      ));
    }
    if (results.isNotEmpty) {
      setState(() => users = localUser);
    }
  }
}

class UserListTile extends StatelessWidget {
  const UserListTile({super.key,
    required this.user,
    this.bgColor = Colors.black,
    this.fgColor,
    this.subColor,
    this.onTap,
    this.viewOnly = true,
  });

  final User user;
  final Color bgColor;
  final Color? fgColor, subColor;
  final void Function()? onTap;
  final bool viewOnly;

  @override
  Widget build(BuildContext context) {
    printTrack("Building List Tile View!");
    return Card(
      color: bgColor,
      child: ListTile(
        selectedColor: bgColor,
        selectedTileColor: bgColor,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (BuildContext context) {
              // NOTE: make userview from listview read only if user want to change his/her profile,
              // it should be done in in profile tile from home profile drawer.
              return UserView(
                user: user,
                viewOnly: viewOnly,
              );
            }
          ));
        },
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 32,
          // NOTE: use first letter in Username if no image is provided.
          // TODO: add profile image for user later.
          child: Text(user.name[0],
            style: TextStyle(
              color: fgColor,
              fontSize: 24,
            ),
          )
        ),
        subtitle: Text(user.isAdmin ? "Admin" : "User"),
        title: Text(user.name,
        ),
        subtitleTextStyle: const TextStyle(
          fontSize: 20,
        ),
        titleTextStyle: TextStyle(
          color: fgColor,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }
}
