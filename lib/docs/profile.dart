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
  Future<bool> update() async {
    if (await valuesNotValid() || isNew(this)) return false;
    final Map<String, Object?> values = {
      "name": name,
    };
    printWarn("update with values of: ${values.toString()} on profile with id of: $id!");
    final bool success = await Core.database!.update(tableName, values,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) action = DocAction.update;
    return success;
  }

  @override
  Future<bool> insert() async {
    if (!isNew(this)) {
      printInfo("Document is already be in database with id of '$id'");
      return false;
    }
    if (await valuesNotValid()) return false;
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
    return success;
  }

  @override
  Future<bool> delete() async {
    // bool delJEs = await deleteAllAccounts();
    // if (!delJEs) printWarn("No JEs deleted!");
    // bool delAccounts = await deleteAllAccounts();
    // if (!delAccounts) printError("No Accounts deleted!");
    final bool success = await Core.database!.delete(
      tableName,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) action = DocAction.delete;
    return success;
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
