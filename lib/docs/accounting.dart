import "package:avert/docs/document.dart";
import "package:avert/ui/module.dart";
import "package:avert/docs/profile.dart";

import "package:avert/utils/common.dart";
import "package:avert/utils/database.dart";
import "package:avert/utils/logger.dart";
import "package:flutter/material.dart";

enum AccountRoot {
  asset,
  liability,
  equity,
  income,
  expense;

  @override
  String toString() {
    return titleCase(name);
  }
}

enum AccountType {
  none,
  cash,
  bank,
  receivable,
  inventory,
  fixedAsset,
  depreciation,
  accumDepreciation,
  cwip,
  payable,
  temporary,
  roundoff,
  cogs,
  tax,
  investment;

  @override
  String toString() => name;

  String get displayName => titleCase(name);
}

class Account implements Document {
  Account(this.profile, {
    this.root = AccountRoot.asset,
    this.id = 0,
    this.name = "",
    this.parentID = 0,
    this.type = AccountType.none,
    this.isGroup = false,
    int createdAt = 0,
    this.action = DocAction.none,
  }) : createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  Account.asset({
    required Profile profile,
    int id = 0,
    String name = "",
    int parentID = 0,
    AccountType type = AccountType.none,
  }) : this(
    profile,
    id: id,
    name: name,
    parentID: parentID,
    type: type,
    root: AccountRoot.asset
  );

  Account.liability({
    required Profile profile,
    int id = 0,
    String name = "",
    int parentID = 0,
    AccountType type =  AccountType.none,
  }) : this(
    profile,
    id: id,
    name: name,
    parentID: parentID,
    type: type,
    root: AccountRoot.liability
  );

  Account.equity({
    required Profile profile,
    int id = 0,
    String name = "",
    int parentID = 0,
    AccountType type =  AccountType.none,
  }) : this(
    profile,
    id: id,
    name: name,
    parentID: parentID,
    type: type,
    root: AccountRoot.equity
  );

  Account.income({
    required Profile profile,
    int id = 0,
    String name = "",
    int parentID = 0,
    AccountType type =  AccountType.none,
  }) : this(
    profile,
    id: id,
    name: name,
    parentID: parentID,
    type: type,
    root: AccountRoot.income
  );

  Account.expense({
    required Profile profile,
    int id = 0,
    String name = "",
    int parentID = 0,
    AccountType type =  AccountType.none,
  }) : this(
    profile,
    id: id,
    name: name,
    parentID: parentID,
    type: type,
    root: AccountRoot.expense
  );

  Account.map({
    required Profile profile,
    required Object parentID,
    required Object id,
    required Object name,
    required Object root,
    required Object type,
    required Object createdAt,
    required Object isGroup,
  }): this(
    profile,
    id: id as int,
    name: name as String,
    createdAt: createdAt as int,
    isGroup: isGroup as int == 1,
    root: AccountRoot.values[root as int],
    type: AccountType.values.byName(type as String),
    parentID: parentID as int,
  );

  @override
  int id;

  @override
  String name;

  @override
  final DateTime createdAt;

  @override
  DocAction action;

  final Profile profile;

  AccountRoot root;
  AccountType type;
  bool isGroup;
  int parentID;

  static String get tableName => "accounts";
  static String get tableQuery => """ CREATE TABLE $tableName(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    createdAt INTEGER NOT NULL,
    profile_id INTEGER NOT NULL,
    is_group INTEGER NOT NULL,
    parent_id INTEGER,
    root INTEGER NOT NULL,
    type TEXT NOT NULL
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

  @override
  Future<bool> insert() async {
    if (!isNew(this) || await valuesNotValid()) {
      printInfo("Document Account:$name is already be in database with id of '$id'");
      return false;
    }

    int now = DateTime.now().millisecondsSinceEpoch;

    Map<String, Object?> values = {
      "name": name,
      "createdAt": now,
      "profile_id": profile.id,
      "root": root.index,
      "type": type.toString(),
      "parent_id": parentID,
      "is_group": isGroup ? 1 : 0,
    };

    printWarn("creating profile with values of: ${values.toString()}");
    id = await Core.database!.insert(tableName, values);
    printSuccess("profile created with id of $id");
    final success = id > 0;
    if (success) action = DocAction.insert;
    return success;
  }

  @override
  Future<bool> update() async {
    if (await valuesNotValid() || isNew(this) || await hasChild) {
      return false;
    }

    Map<String, Object?> values = {
      "name": name,
      "root": root.index,
      "type": type.toString(),
      "parent_id": parentID,
      "is_group": isGroup ? 1 : 0,
    };

    printWarn("update with values of: ${values.toString()} on account with id of: $id!");

    bool success = await Core.database!.update(tableName, values,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) action = DocAction.update;

    return success;
  }

  Future<bool> valuesNotValid() async {
    bool hasDuplicates = await nameExists(this, tableName);
    return name.isEmpty || hasDuplicates;
  }

  Future<bool> get hasChild async {
    List<Map<String, Object?>> values = await Core.database!.query(tableName,
      columns: ["id"],
      where: "id != ? and parent_id = ?",
      whereArgs: [id , id],
    );

    return values.isNotEmpty;
  }

  Future<List<Account>> fetchChildren() async {
    List<Account> list = [];
    String where = "profile_id = ? and parent_id = ?";
    List<Object> whereArgs = [profile.id, id];
    List<Map<String, Object?>> values = await Core.database!.query(tableName,
      where: where,
      whereArgs: whereArgs,
    );

    if (values.isEmpty) return list;

    for (Map<String, Object?> value in values ) {
      printAssert(value["profile_id"] as int == profile.id, "Account belongs to a different profile.");
      list.add(Account.map(
        profile: profile,
        id: value["id"]!,
        name: value["name"]!,
        createdAt: value["createdAt"]!,
        root: value["root"]!,
        type: value["type"]!,
        parentID: value["parent_id"]!,
        isGroup: value["is_group"]!,
      ));
    }
    return list;
  }

  static Future<List<Account>> fetchParents(Profile profile, AccountRoot? root, AccountType? type) async {
    List<Account> list = [];
    String where = "profile_id = ? and is_group = ?";
    List<Object> whereArgs = [profile.id, 1];
    if (root != null) {
      where = "$where and root = ?";
      whereArgs.add(root.index);
    }
    if (type != null) {
      where = "$where and type = ?";
      whereArgs.add(type.toString());
    }
    List<Map<String, Object?>> values = await Core.database!.query(tableName,
      where: where,
      whereArgs: whereArgs,
    );

    if (values.isEmpty) return list;

    for (Map<String, Object?> value in values ) {
      printAssert(value["profile_id"] as int == profile.id, "Account belongs to a different profile.");
      list.add(Account.map(
        profile: profile,
        id: value["id"]!,
        name: value["name"]!,
        createdAt: value["createdAt"]!,
        root: value["root"]!,
        type: value["type"]!,
        parentID: value["parent_id"]!,
        isGroup: value["is_group"]!,
      ));
      // printInfo("fetch with value of: ${value.toString()}");
    }
    return list;
  }
}

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
    this.value = 0,
    this.account,
    this.description = "",
    int createdAt = 0,
    this.action = DocAction.none,
  }):
  id = 0,
  name = name.toString(),
  createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  AccountingEntry.map({
    required this.name,
    required this.journalEntry,
    required this.id,
    required this.value,
    required this.type,
    required this.account,
    required this.description,
    required this.createdAt,
    this.action = DocAction.none,
  });

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
    value REAL NOT NULL
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
      printInfo("Document Accounting entry:$name is already be in database with id of '$id'");
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
    return account == null || type == EntryType.none || value == 0;
  }
}

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

    if (fails > 0) throw ErrorHint("Something went wrong deleting accounting Entries in the db!");

    final bool success = await Core.database!.delete(
      tableName,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) action = DocAction.delete;
    return success;
  }

  Future<bool> valuesNotValid() async {
    return name.isEmpty;
  }

  @override
  Future<bool> insert() async {
    if (!isNew(this) || await valuesNotValid()) {
      printInfo("Document Journal entry:$name is already be in database with id of '$id'");
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
    if (success) {
      action = DocAction.insert;
    } else {
      await Core.database!.delete( tableName, where: "id = ?", whereArgs: [id]);
    }
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
