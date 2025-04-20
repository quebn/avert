import "package:avert/docs/document.dart";
import "package:avert/ui/module.dart";

import "package:avert/utils/common.dart";
import "package:avert/utils/database.dart";
import "package:avert/utils/logger.dart";

import "account.dart";
import "journal_entry.dart";

enum EntryType {
  none(0),
  debit(1),
  credit(2);

  const EntryType(this.value);
  final int value;

  String get abbrev {
    switch(value) {
      case 1: return "Dr";
      case 2: return "Cr";
      default: return "Na";
    }
  }

  @override
  String toString() => titleCase(name);
}

class AccountingEntry implements Document {
  AccountingEntry({
    required int name,
    required this.journalEntry,
    this.type = EntryType.none,
    this.id = 0,
    this.value = 0,
    this.account,
    this.description = "",
    int createdAt = 0,
    this.action = DocAction.none,
  }):
  name = name.toString(),
  createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  AccountingEntry.debit({
    required int name,
    required this.journalEntry,
    this.id = 0,
    this.value = 0,
    this.account,
    this.description = "",
    int createdAt = 0,
    this.action = DocAction.none,
  }):
  type = EntryType.debit,
  name = name.toString(),
  createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  AccountingEntry.credit({
    required int name,
    required this.journalEntry,
    this.id = 0,
    this.value = 0,
    this.account,
    this.description = "",
    int createdAt = 0,
    this.action = DocAction.none,
  }):
  type = EntryType.credit,
  name = name.toString(),
  createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);


  @override
  DocAction action;

  @override
  int id;

  @override
  String name;

  Account? account;
  EntryType type;
  double value;
  final JournalEntry journalEntry;
  String description;

  @override
  final DateTime createdAt;

  static String get tableName => "accounting_entries";
  static String get tableQuery => """CREATE TABLE $tableName(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    createdAt INTEGER NOT NULL,
    account_id INTEGER,
    journal_entry_id INTEGER,
    description TEXT,
    type INTEGER NOT NULL,
    value INTEGER NOT NULL
  )""";

  @override
  Future<bool> delete() async {
    final bool success =  await Core.database!.delete(tableName,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) action = DocAction.delete;
    return success;
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
      "account_id": account!.id,
      "journal_entry_id": journalEntry.id,
      "createdAt": now,
      "description": description,
      "type": type.value,
      "value": value,
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
      "account_id": account!.id,
      "description": description,
      "type": type.value,
      "value": value,
    };

    printWarn("update with values of: ${values.toString()} on entry with id of: $id!");

    bool success = await Core.database!.update(tableName, values,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) action = DocAction.update;
    return success;
  }

  Future<bool> valuesNotValid() async {
    bool hasDuplicates = await exists(this, tableName);
    return name.isEmpty || hasDuplicates || account == null || type == EntryType.none;
  }
}
