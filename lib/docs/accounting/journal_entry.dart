import "package:avert/docs/document.dart";
import "package:avert/ui/module.dart";
import "package:avert/docs/profile.dart";
import "package:avert/utils/common.dart";
import "package:avert/utils/database.dart";
import "package:avert/utils/logger.dart";

import "accounting_entry.dart";

class JournalEntry implements Document {
  JournalEntry(this.profile, {
    this.name = "",
    this.id = 0,
    this.action = DocAction.none,
    int createdAt = 0,
    this.entries = const [],
    DateTime? postedAt,
    this.note = "",
  }) : createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt), postedAt = postedAt ?? DateTime.now();

  @override
  DocAction action;

  @override
  int id;

  @override
  String name;

  @override
  DateTime createdAt;

  DateTime? postedAt;
  List<AccountingEntry> entries;
  Profile profile;
  String note;

  static String get tableName => "journal_entries";
  static String get tableQuery => """ CREATE TABLE $tableName(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    createdAt INTEGER NOT NULL,
    profile_id INTEGER NOT NULL,
    postedAt INTEGER,
    note TEXT
  ) """;

  @override
  Future<bool> delete() async {
    final bool success =  await Core.database!.delete(tableName,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) action = DocAction.delete;
    return success;
  }

  Future<bool> valuesNotValid() async {
    bool hasDuplicates = await exists(this, tableName);
    return name.isEmpty || hasDuplicates;
  }

  @override
  Future<bool> insert() async {
    if (!isNew(this) || await valuesNotValid()) {
      printInfo("Document is already be in database with id of '$id'");
      return false;
    }
    int now = DateTime.now().millisecondsSinceEpoch;
    Map<String, Object?> values = {
      "name": name,
      "profile_id": profile.id,
      "note": note,
      "createdAt": now,
      "postedAt": postedAt?.millisecondsSinceEpoch ?? 0,
    };
    printWarn("creating entry with values of: ${values.toString()}");
    id = await Core.database!.insert(tableName, values);
    printSuccess("entry created with id of $id");
    final success = id > 0;
    if (success) action = DocAction.insert;
    return success;
  }

  @override
  Future<bool> update() async {
    if (await valuesNotValid() || isNew(this)) {
      return false;
    }

    Map<String, Object?> values = {
      "name": name,
      "note": note,
      "postedAt": postedAt?.millisecondsSinceEpoch ?? 0,
    };

    printWarn("update with values of: ${values.toString()} on journal entry with id of: $id!");

    bool success = await Core.database!.update(tableName, values,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) action = DocAction.update;
    return success;
  }
}
