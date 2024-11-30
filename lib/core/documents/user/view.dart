import "package:avert/core/core.dart";
import "package:avert/core/components/avert_document.dart";
import "package:avert/core/components/avert_button.dart";

class UserView extends StatefulWidget  {
  const UserView({super.key,
    required this.document,
    this.onSave,
    this.onDelete,
    this.onPop,
    this.onSetDefault,
    this.viewOnly = true,
  });

  final User document;
  final void Function()? onSave, onDelete, onPop;
  final bool Function()? onSetDefault;
  final bool viewOnly;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<UserView> implements DocumentView {
  Future<bool?> confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete User?"),
          content: Text(
            "Are you sure you want to delete '${widget.document.name}'? deleting this user will direct you to Login Screen."
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

  @override
  Future<void> deleteDocument() async {
    final bool shouldDelete = await confirmDelete() ?? false;

    if (!shouldDelete) {
      return;
    }

    final bool success = await widget.document.delete();
    printWarn("Deleting user:${widget.document.name} with id of: ${widget.document.id}");

    if (success && mounted) {
      printSuccess("User Deleted!");
      Navigator.maybePop(context);
      if (widget.onDelete != null) widget.onDelete!();
    } else {
      printInfo("User not Deleted!");
    }
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building User Document View");
    return AvertDocumentView(
      name: widget.document.name,
      image: IconButton(
        icon: CircleAvatar(
          radius: 50,
          child: Text(widget.document.name[0].toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 50,
            ),
          ),
        ),
        onPressed: () => printInfo("Pressed Profile Pic"),
      ),
      titleChildren: [
        Text(widget.document.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(widget.document.isAdmin ? "Admin" : "User",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ],
      //formKey: key,
      //isDirty: isDirty,
      body: profileBody(),
      //floationActionButton: !isDirty ? null : IconButton.filled(
      //  onPressed: insertDocument,
      //  iconSize: 48,
      //  icon: Icon(Icons.save_rounded)
      //),
    );
  }

  Widget profileBody() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          dangerSection(),
        ],
      ),
    );
  }

  Widget dangerSection() => Container(
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
              return UserView(
                document: user,
                viewOnly: viewOnly,
              );
            }
          ));
        },
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 32,
          // TODO: add profile image for user later.
          child: Text(user.name[0].toUpperCase(),
            style: TextStyle(
              color: bgColor,
              fontSize: 24,
            ),
          )
        ),
        subtitle: Text(user.isAdmin ? "Admin" : "User"),
        title: Text(user.name),
        subtitleTextStyle: TextStyle(
          color: fgColor,
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
