import "package:avert/docs/accounting/account.dart";
import "package:avert/docs/document.dart";
import "package:avert/ui/module.dart";
import "package:avert/docs/profile.dart";
import "package:avert/utils/common.dart";
import "package:avert/utils/database.dart";
import "package:avert/utils/logger.dart";
import "package:flutter/foundation.dart";

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

  JournalEntry.map(this.profile, {
    required this.name,
    required this.id,
    required this.action,
    required this.createdAt,
    required this.entries,
    required this.postedAt,
    required this.note,
  });

  @override
  DocAction action;

  @override
  int id;

  @override
  String name;

  @override
  DateTime createdAt;

  DateTime postedAt;
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
    final int fails = await Core.database!.delete(
      AccountingEntry.tableName,
      where: "journal_entry_id = ?",
      whereArgs: [id],
    );

    if (fails < 2) throw ErrorHint("Something went wrong deleting accounting Entries in the db!");

    final bool success = await Core.database!.delete(
      tableName,
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
      "postedAt": postedAt.millisecondsSinceEpoch,
    };
    printWarn("creating entry with values of: ${values.toString()}");
    id = await Core.database!.insert(tableName, values);
    printSuccess("entry created with id of $id");
    List<AccountingEntry> fails = await insertDocuments(entries);
    final success = id > 0 && fails.isEmpty;
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
      "postedAt": postedAt.millisecondsSinceEpoch,
    };

    printWarn("update with values of: ${values.toString()} on journal entry with id of: $id!");

    bool success = await Core.database!.update(tableName, values,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) action = DocAction.update;
    return success;
  }

  Future<void> fetchEntries() async {
    if (id == 0 || entries.isNotEmpty) return;
    final String query = """
    SELECT ae.*,
      a.name as a_name,
      a.createdAt as a_createdAt,
      a.profile_id as a_profile_id,
      a.is_group as a_is_group,
      a.parent_id as a_parent_id,
      a.root as a_root,
      a.type as a_type
    FROM ${AccountingEntry.tableName} ae
    JOIN ${Account.tableName} a ON ae.account_id = a.id
    WHERE ae.journal_entry_id = $id
    """;
    List<Map<String, Object?>> values = await Core.database!.rawQuery(query);
    final List<AccountingEntry> list = [];
    for (Map<String, Object?> value in values) {
      final DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(value["createdAt"]! as int);
      assert(value["a_profile_id"]! as int == profile.id);
      list.add(AccountingEntry.map(
        name: value["name"]! as String,
        action: DocAction.none,
        description: value["description"]! as String,
        id: value["id"]! as int,
        type: EntryType.values[(value["type"]! as int)],
        value: value["value"]! as double,
        createdAt: createdAt,
        journalEntry: this,
        account: Account.map(
          profile: profile,
          id: value["account_id"]!,
          name: value["a_name"]!,
          parentID: value["a_parent_id"]!,
          root: value["a_root"]!,
          type: value["a_type"]!,
          isGroup: value["a_is_group"]!,
          createdAt: value["a_createdAt"]!,
        ),
      ));
    }
    entries = list;
  }
}
