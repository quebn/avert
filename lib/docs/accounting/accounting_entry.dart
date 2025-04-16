import "package:avert/docs/document.dart";
import "package:avert/ui/module.dart";

import "package:avert/utils/common.dart";
import "package:avert/utils/database.dart";
import "package:avert/utils/logger.dart";

import "account.dart";
import "journal_entry.dart";

class AccountingEntry implements Document {
  AccountingEntry({
    required int name,
    required this.journalEntry,
    this.id = 0,
    this.debit = 0,
    this.credit = 0,
    this.account,
    this.description = "",
    int createdAt = 0,
    this.action = DocAction.none,
  }):
  name = name.toString(),
  createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  @override
  DocAction action;

  @override
  int id;

  @override
  String name;

  Account? account;
  double debit, credit;
  JournalEntry journalEntry;
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
    debit INTEGER,
    credit INTEGER
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
      "createdAt": now,
      "description": description,
      "debit": debit,
      "credit": credit,
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
      "debit": debit,
      "credit": credit,
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
    return name.isEmpty || hasDuplicates || account == null;
  }
}
