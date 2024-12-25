import "package:avert/core/core.dart";
import "package:forui/forui.dart";

Future<List<Profile>> fetchAllProfile({Database? database}) async {
  List<Map<String, Object?>> values = await (database ?? Core.database!).query(Profile.tableName,
    columns: ["id", "name", "createdAt"],
  );

  List<Profile> list = [];

  if (values.isNotEmpty) {
    for (Map<String, Object?> v in values) {
      list.add(Profile.map(
        id: v["id"]!,
        name: v["name"]!,
        createdAt: v["createdAt"]!,
      ));
    }
  }

  return list;
}

void notify(BuildContext context, String msg) {
  final SnackBar snackBar = SnackBar(
    showCloseIcon: true,
    content: Center(
      child: Text(msg),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<bool?> confirm(BuildContext context) {
  printWarn("showing pop confirmation dialog");
  return showAdaptiveDialog<bool>(
    context: context,
    builder: (BuildContext context) => FDialog(
      direction: Axis.horizontal,
      title: const Text("Are you sure?"),
      body: const Text("Are you sure you want to leave this page?"),
      actions: <Widget>[
        FButton(
          label: const Text("Stay"),
          style: FButtonStyle.outline,
          onPress: () {
            Navigator.of(context).pop(false);
          },
        ),
        FButton(
          label: const Text("Leave"),
          onPress: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    ),
  );
}
