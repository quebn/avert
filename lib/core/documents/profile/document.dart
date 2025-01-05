import "package:avert/core/core.dart";
import "package:avert/core/utils/database.dart";

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
    bool hasDuplicates = await exists(this, tableName);
    return name.isEmpty || hasDuplicates;
  }

  @override
  Future<Result<Profile>> update() async {
    if (await valuesNotValid() || isNew(this)) return Result<Profile>.empty();
    Map<String, Object?> values = {
      "name": name,
    };
    printWarn("update with values of: ${values.toString()} on profile with id of: $id!");
    bool success = await Core.database!.update(tableName, values,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (!success) return Result<Profile>.empty();
    return Result<Profile>.update(this);
  }

  @override
  Future<Result<Profile>> insert() async {
    if (!isNew(this)) {
      printInfo("Document is already be in database with id of '$id'");
      return Result<Profile>.empty();
    }
    if (await valuesNotValid()) return Result<Profile>.empty();
    int now = DateTime.now().millisecondsSinceEpoch;
    Map<String, Object?> values = {
      "name": name,
      "createdAt": now,
    };
    printWarn("creating profile with values of: ${values.toString()}");
    id = await Core.database!.insert(tableName, values);
    printSuccess("profile created with id of $id");
    if (id != 0) return Result<Profile>.empty();
    return Result.insert(this);
  }

  @override
  Future<Result<Profile>> delete() async {
    bool success = await Core.database!.delete(tableName,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;

    if (!success) return Result<Profile>.empty();

    return Result<Profile>.delete(this);
  }
}
