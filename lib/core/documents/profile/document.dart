import "package:avert/core/core.dart";

class Profile implements Document {
  Profile({
    this.id = 0,
    this.name = "",
    int createdAt = 0,
  }): createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  Profile.map({
    required Object id,
    required Object name,
    required Object createdAt,
  }): this(
    id: id as int,
    name: name as String,
    createdAt: createdAt as int
  );

  @override
  int id;

  @override
  String name;

  @override
  final DateTime createdAt;

  static String get tableName => "profiles";

  static String get tableQuery => """
    CREATE TABLE $tableName(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      createdAt INTEGER NOT NULL
    )
  """;

  Future<bool> valuesNotValid() async {
    bool hasDuplicates = await exists();
    return name.isEmpty || hasDuplicates;
  }

  Future<bool> exists() async {
    List<Map<String, Object?>> values = await Core.database!.query(tableName,
      columns: ["id"],
      where: "name = ?",
      whereArgs: [name],
    );
    return values.isNotEmpty;
  }

  @override
  Future<bool> update() async {
    if (await valuesNotValid() || isNew(this)) return false;
    Map<String, Object?> values = {
      "name": name,
    };
    printWarn("update with values of: ${values.toString()} on profile with id of: $id!");
    int r = await Core.database!.update(tableName, values,
      where: "id = ?",
      whereArgs: [id],
    );
    return r == 1;
  }

  @override
  Future<bool> insert() async {
    if (!isNew(this)) {
      printInfo("Document is already be in database with id of '$id'");
      return false;
    }
    if (await valuesNotValid()) return false;
    int now = DateTime.now().millisecondsSinceEpoch;
    Map<String, Object?> values = {
      "name": name,
      "createdAt": now,
    };
    printWarn("creating profile with values of: ${values.toString()}");
    id = await Core.database!.insert(tableName, values);
    printSuccess("profile created with id of $id");
    return id != 0;
  }

  @override
  Future<bool> delete() async {
    int result =  await Core.database!.delete(tableName,
      where: "id = ?",
      whereArgs: [id],
    );
    return result == id;
  }
}

abstract class ProfileTabView {
  Widget getProfileTabView(BuildContext context);
}
