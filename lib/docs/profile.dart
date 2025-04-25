import 'package:avert/docs/document.dart';
import 'package:avert/ui/module.dart';
import 'package:avert/utils/common.dart';
import 'package:avert/utils/database.dart';
import 'package:avert/utils/logger.dart';

class Profile implements Document {
  Profile({
    this.id = 0,
    this.name = "",
    int createdAt = 0,
    this.action = DocAction.none,
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

  @override
  DocAction action;

  static String get tableName => "profiles";

  static String get tableQuery => """
    CREATE TABLE $tableName(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      createdAt INTEGER NOT NULL
    )
  """;

  Future<bool> valuesNotValid() async {
    final bool hasDuplicates = await exist(this, tableName);
    return name.isEmpty || hasDuplicates;
  }

  @override
  Future<String?> update() async {
    if (await valuesNotValid() || isNew(this)) {
      return "Account:$name values not valid is a new document";
    }
    final Map<String, Object?> values = {
      "name": name,
    };
    printWarn("update with values of: ${values.toString()} on profile with id of: $id!");
    final bool success = await Core.database!.update(tableName, values,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) action = DocAction.update;
    return success ? null : "Profile:$name failed to update in database";
  }

  @override
  Future<String?> insert() async {
    if (!isNew(this) || await valuesNotValid()) {
      return "Profile:$name values not valid or is not new";
    }
    final int now = DateTime.now().millisecondsSinceEpoch;
    final Map<String, Object?> values = {
      "name": name,
      "createdAt": now,
    };
    printWarn("creating profile with values of: ${values.toString()}");
    id = await Core.database!.insert(tableName, values);
    printSuccess("profile created with id of $id");
    final bool success = id > 0;
    if (success) action = DocAction.insert;
    return success ? null : "Profile:$name failed to insert to database";
  }

  @override
  Future<String?> delete() async {
    final bool success = await Core.database!.delete(
      tableName,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) action = DocAction.delete;
    return success ? null : "Profile:$name failed to delete from database";
  }

  Future<bool> nameExists(Document document, String table) async {
    final List<Map<String, Object?>> values = await Core.database!.query(
      table,
      columns: ["id"],
      where: "name = ? and profile_id = ?",
      whereArgs: [document.name, id],
    );
    return values.isNotEmpty;
  }
}
