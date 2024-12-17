import "package:avert/core/components/avert_document.dart";
import "package:avert/core/core.dart";
import "package:avert/core/utils/ui.dart";
import "package:forui/forui.dart";

class UserView extends StatefulWidget  {
  const UserView({super.key,
    required this.document,
    required this.user,
    this.onUpdate,
    this.onDelete,
  });

  final User document, user;
  final void Function()? onUpdate, onDelete;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<UserView> with SingleTickerProviderStateMixin implements DocumentView {
  late final FPopoverController _controller = FPopoverController(vsync: this);

  bool get canDelete => widget.user.isAdmin || widget.user == widget.document;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building User Document View");
    return AvertDocumentView(
      controller: _controller,
      name: "User",
      title: widget.document.name,
      subtitle: widget.document.isAdmin ? "Admin" : "User",
      content: Container(),
      onEdit: widget.onUpdate,
      // NOTE: conditions if user can be deleted.
      // current condition implemented:
      //     - if the user document is not a admin.

      // TODO: conditions to implement:
      // - if current user is allowed to modify users (Admin).
      // - if current user is allowed to modify users (Admin).
      onDelete: canDelete ? deleteDocument : null,
    );
  }

  Future<bool?> confirmDelete() {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (BuildContext context) => FDialog(
        direction: Axis.horizontal,
        title: const Text("Delete User?"),
        body: Text(
          "Are you sure you want to delete '${widget.document.name}'? deleting this user will direct you to Login Screen."
        ),
        actions: <Widget>[
          FButton(
            label: const Text("No"),
            style: FButtonStyle.outline,
            onPress: () {
              Navigator.of(context).pop(false);
            },
          ),
          FButton(
            style: FButtonStyle.destructive,
            label: const Text("Yes"),
            onPress: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
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
      Navigator.of(context).pop();
      if (widget.onDelete != null) widget.onDelete!();
      notify(context, "User '${widget.document.name}' successfully deleted!");
    }
  }
}

//class UserListView extends StatefulWidget {
//  const UserListView({super.key, required this.user});
//
//  final User user;
//  @override
//  State<StatefulWidget> createState() => _ListViewState();
//}
//
//class _ListViewState extends State<UserListView> {
//  List<User> users = [];
//
//  @override
//  Widget build(BuildContext context) {
//    printTrack("Building User List View");
//    if (users.isEmpty) {
//      users.add(widget.user);
//      fetchOtherUsers();
//    }
//    return Scaffold(
//      appBar: AppBar(
//        title: const Text("Users"),
//      ),
//      body: ListView.builder(
//        padding: EdgeInsets.all(8),
//        itemCount: users.length,
//        itemBuilder: (BuildContext context, int index) {
//          return UserListTile(
//            user: users[index],
//          );
//        },
//      ),
//    );
//  }
//
//  Future<void> fetchOtherUsers() async {
//    List<Map<String, Object?>> results = await Core.database!.query("users",
//      columns: ["id", "name", "createdAt"],
//      where: "id != ?",
//      whereArgs: [widget.user.id]
//    );
//    List<User> localUser = users;
//    for (Map<String, Object?> result in results ) {
//      localUser.add(User.fromQuery(
//        id: result["id"]!,
//        name: result["name"]!,
//        createdAt: result["createdAt"]!,
//      ));
//    }
//    if (results.isNotEmpty) {
//      setState(() => users = localUser);
//    }
//  }
//}
//
//class UserListTile extends StatelessWidget {
//  const UserListTile({super.key,
//    required this.user,
//    this.bgColor = Colors.black,
//    this.fgColor,
//    this.subColor,
//    this.onTap,
//    this.viewOnly = true,
//  });
//
//  final User user;
//  final Color bgColor;
//  final Color? fgColor, subColor;
//  final void Function()? onTap;
//  final bool viewOnly;
//
//  @override
//  Widget build(BuildContext context) {
//    printTrack("Building List Tile View!");
//    return Card(
//      color: bgColor,
//      child: ListTile(
//        selectedColor: bgColor,
//        selectedTileColor: bgColor,
//        onTap: () {
//          Navigator.push(context, MaterialPageRoute(
//            builder: (BuildContext context) {
//              return UserView(
//                document: user,
//                viewOnly: viewOnly,
//              );
//            }
//          ));
//        },
//        contentPadding: const EdgeInsets.all(10),
//        leading: CircleAvatar(
//          backgroundColor: Colors.white,
//          radius: 32,
//          // TODO: add profile image for user later.
//          child: Text(user.name[0].toUpperCase(),
//            style: TextStyle(
//              color: bgColor,
//              fontSize: 24,
//            ),
//          )
//        ),
//        subtitle: Text(user.isAdmin ? "Admin" : "User"),
//        title: Text(user.name),
//        subtitleTextStyle: TextStyle(
//          color: fgColor,
//          fontSize: 20,
//        ),
//        titleTextStyle: TextStyle(
//          color: fgColor,
//          fontWeight: FontWeight.bold,
//          fontSize: 24,
//        ),
//      ),
//    );
//  }
//}
