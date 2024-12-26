import "package:avert/core/core.dart";

void createCoreTables(Batch batch) {
  List<String> queries = [
    Profile.tableQuery,
    // Task.getTableQuery() // NOTE: Not planned.
  ];

  for (String query in queries) {
    batch.execute(query);
  }
}

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

Future<bool> exists(Document document, String table) async {
  List<Map<String, Object?>> values = await Core.database!.query(table,
    columns: ["id"],
    where: "name = ?",
    whereArgs: [document.name],
  );
  return values.isNotEmpty;
}
