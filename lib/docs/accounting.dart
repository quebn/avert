import "package:avert/docs/document.dart";
import "package:avert/ui/module.dart";
import "package:avert/docs/profile.dart";

import "package:avert/utils/common.dart";
import "package:avert/utils/database.dart";
import "package:avert/utils/logger.dart";

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

  EntryType get defaultType {
    switch(name) {
      case "asset":
      case "expense": return EntryType.debit;
      case "liability":
      case "equity":
      case "income": return EntryType.credit;
      default: return EntryType.none;
    }
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

class AccountValue {
  AccountValue(
    this.type,
    this.amount,
  );

  AccountValue.zero():type = EntryType.none, amount = 0;

  AccountValue.debit(
    this.amount,
  ): type = EntryType.debit;

  AccountValue.credit(
    this.amount,
  ): type = EntryType.credit;

  EntryType type;
  double amount;

  @override
  String toString() => "${amount.toString()} ${type.abbrev}";

  bool get isDebit => type == EntryType.debit;
  bool get isCredit => type == EntryType.credit;
  bool equals(AccountValue value) => amount == value.amount && type == value.type;

  AccountValue operator +(AccountValue value) {
    printAssert(amount >= 0, "Total should not be less than 0");
    if (amount == 0 || type == EntryType.none) {
      amount = value.amount;
      type = value.type;
    } else {
      if (type != type) {
        if (amount < value.amount) {
          amount = value.amount - amount;
          type = value.type;
        } else {
          amount -= value.amount;
        }
      } else {
        amount += value.amount;
      }
    }
    return this;
  }
}

class Account implements Document {
  Account(this.profile, {
    this.root = AccountRoot.asset,
    this.id = 0,
    this.name = "",
    this.parentID = 0,
    this.type = AccountType.none,
    this.isGroup = false,
    this.positive = EntryType.none,
    int createdAt = 0,
    this.action = DocAction.none,
    this.children,
  }) : createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  Account.asset({
    required this.profile,
    required this.name,
    this.id = 0,
    this.parentID = 0,
    this.type = AccountType.none,
    this.children,
    this.positive = EntryType.debit,
    int createdAt = 0,
  }) :
    isGroup = children != null,
    action = DocAction.none,
    root = AccountRoot.asset,
    createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  Account.liability({
    required this.profile,
    required this.name,
    this.id = 0,
    this.parentID = 0,
    this.type = AccountType.none,
    this.children,
    this.positive = EntryType.credit,
    int createdAt = 0,
  }) :
    isGroup = children != null,
    action = DocAction.none,
    root = AccountRoot.liability,
    createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  Account.equity({
    required this.profile,
    required this.name,
    this.id = 0,
    this.parentID = 0,
    this.type = AccountType.none,
    this.children,
    this.positive = EntryType.credit,
    int createdAt = 0,
  }) :
    isGroup = children != null,
    action = DocAction.none,
    root = AccountRoot.equity,
    createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  Account.income({
    required this.profile,
    required this.name,
    this.id = 0,
    this.parentID = 0,
    this.type = AccountType.none,
    this.children,
    this.positive = EntryType.credit,
    int createdAt = 0,
  }) :
    isGroup = children != null,
    action = DocAction.none,
    root = AccountRoot.income,
    createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  Account.expense({
    required this.profile,
    required this.name,
    this.id = 0,
    this.parentID = 0,
    this.type = AccountType.none,
    this.children,
    this.positive = EntryType.debit,
    int createdAt = 0,
  }) :
    isGroup = children != null,
    action = DocAction.none,
    root = AccountRoot.expense,
    createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  Account.map({
    required Profile profile,
    required Object parentID,
    required Object id,
    required Object name,
    required Object root,
    required Object type,
    required Object createdAt,
    required Object isGroup,
    required Object positive,
  }): this(
    profile,
    id: id as int,
    name: name as String,
    createdAt: createdAt as int,
    isGroup: isGroup as int == 1,
    positive: EntryType.values[positive as int],
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
  EntryType positive;
  bool isGroup;
  int parentID;
  List<Account>? children;

  static String get tableName => "accounts";
  static String get tableQuery => """ CREATE TABLE $tableName(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    profile_id INTEGER NOT NULL,
    is_group INTEGER NOT NULL,
    parent_id INTEGER,
    positive INTEGER NOT NULL,
    root INTEGER NOT NULL,
    type TEXT NOT NULL,
    FOREIGN KEY(profile_id) REFERENCES ${Profile.tableName}(id) ON DELETE CASCADE
  ) """;

  @override
  Future<String?> delete() async {
    if (await hasChild) {
      return "Could not delete: '$name' has child accounts";
    }
    if (await hasEntries()) {
      return "Account:$name has entries available and cannot be deleted!";
    }
    final bool success = await Core.database!.delete(tableName,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) action = DocAction.delete;
    return success ? null : "Account:$name could not be deleted in the database!";
  }

  @override
  Future<String?> insert() async {
    if (!isNew(this) || await valuesNotValid()) {
      return "Document Account:$name is already be in database with id of '$id'";
    }

    final int now = DateTime.now().millisecondsSinceEpoch;

    final Map<String, Object?> values = {
      "name": name,
      "created_at": now,
      "profile_id": profile.id,
      "positive": positive.index,
      "root": root.index,
      "type": type.toString(),
      "parent_id": parentID,
      "is_group": isGroup ? 1 : 0,
    };

    id = await Core.database!.insert(tableName, values);
    final bool success = id > 0;
    if (success) {
      action = DocAction.insert;
      if (isGroup && children != null && children!.isNotEmpty) {
        for (Account child in children!) {
          child.parentID = id;
          final String? error = await child.insert();
          if (error != null) printWarn(error);
        }
      }
      // check if parent and has children
    }
    return success ? null : "Account:$name failed to insert to Database!";
  }

  @override
  Future<String?> update() async {
    if (await valuesNotValid() || isNew(this) || await hasChild) {
      return "Account:$name values not valid";
    }

    final Map<String, Object?> values = {
      "name": name,
      "root": root.index,
      "type": type.toString(),
      "positive": positive.index,
      "parent_id": parentID,
      "is_group": isGroup ? 1 : 0,
    };

    printSuccess("Account:$id as id, updated with values of: ${values.toString()}");

    final bool success = await Core.database!.update(tableName, values,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) action = DocAction.update;
    return success ? null : "Account:$name failed to edit to database!";
  }

  Future<bool> valuesNotValid() async {
    bool hasDuplicates = await profile.nameExists(this, tableName);
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

  Future<bool> fetchChildren() async {
    if (!isGroup) return false;
    final List<Account> list = [];
    final String where = "profile_id = ? and parent_id = ?";
    final List<Object> whereArgs = [profile.id, id];
    final List<Map<String, Object?>> values = await Core.database!.query(tableName,
      where: where,
      whereArgs: whereArgs,
    );

    if (values.isEmpty) return false;

    profile.mapAccountsToList(list, values);
    children = list;
    return true;
  }

  static Future<List<Account>> fetchParents(Profile profile, AccountRoot? root, AccountType? type) async {
    final List<Account> list = [];
    final List<Object> whereArgs = [profile.id, 1];
    String where = "profile_id = ? and is_group = ?";
    if (root != null) {
      where = "$where and root = ?";
      whereArgs.add(root.index);
    }
    if (type != null) {
      where = "$where and type = ?";
      whereArgs.add(type.toString());
    }
    final List<Map<String, Object?>> values = await Core.database!.query(tableName,
      where: where,
      whereArgs: whereArgs,
    );

    if (values.isEmpty) return list;

    profile.mapAccountsToList(list, values);
    return list;
  }

  Future<bool> hasEntries() async {
    final List<Map<String, Object?>> entries = await Core.database!.query(
      AccountingEntry.tableName,
      columns: ["id"],
      where: "account_id = ?",
      whereArgs: [id],
    );
    return entries.isNotEmpty;
  }

  Future<Account?> fetchParent() async {
    if (parentID == 0) return null;
    final List<Map<String, Object?>> result = await Core.database!.query(
      Account.tableName,
      where: "id = ?",
      whereArgs: [parentID],
    );
    printAssert(result.isNotEmpty, "Account:$name expected result to be not empty got empty instead");
    printAssert(result.length == 1, "Account:$name expected length of 1 of fetchParent result got ${result.length} instead");
    var value = result.first;
    final Account parent = Account.map(
      id: value["id"]!,
      name: value["name"]!,
      parentID: value["parent_id"]!,
      positive: value["postive"]!,
      profile: profile,
      root: value["root"]!,
      type: value["type"]!,
      createdAt: value["created_at"]!,
      isGroup: value["is_group"]!,
    );
    return parent;
  }

  Future<List<int>> getChildrenLeafIDs() async {
    final List<int> ids = [];
    if (!isGroup) return ids;
    final String query = """
    with recursive tree as (
      select id, parent_id, is_group
      from $tableName
      where id = $id

      union all

      select a.id, a.parent_id, a.is_group
      from $tableName a
      inner join tree t on a.parent_id = t.id
    )

    select t.id
    from tree t
    where t.is_group = 0;
    """;
    final List<Map<String, Object?>> values = await Core.database!.rawQuery(query);
    for (final Map<String, Object?> value in values) {
      ids.add(value["id"]! as int);
    }
    return ids;
  }

  Future<AccountValue> getBalance(DateTime at) async {
    final int atMs = at.millisecondsSinceEpoch;
    final String ids = isGroup ? (await getChildrenLeafIDs()).join(",") : "$id";
    final String query = """
      select sum(ae.value) as value, ae.type
      from ${AccountingEntry.tableName} ae
        left outer join ${JournalEntry.tableName} je
        on je.id = ae.journal_entry_id
      where ae.account_id in ($ids) and je.posted_at <= $atMs
      group by type
    """;
    final List<Map<String, Object?>> values = await Core.database!.rawQuery(query);
    printAssert(values.length <= 2, "Account:$name expect query values length to be <= 2, got ${values.length} instead");
    printTrack("Values: ${values.toString()}");
    final EntryType def = positive.isNone ? root.defaultType : positive;
    return calculateBalance(values, def);
  }

  Future<AccountValue> getTotalBalance() async {
    final String ids = isGroup ? (await getChildrenLeafIDs()).join(",") : "$id";
    final String query = """
      select sum(value) as value, type
      from ${AccountingEntry.tableName}
      where account_id in ($ids)
      group by type
    """;
    final List<Map<String, Object?>> values = await Core.database!.rawQuery(query);
    printAssert(values.length <= 2, "Account:$name expect query values length to be <= 2, got ${values.length} instead");
    printTrack("Values: ${values.toString()}");
    final EntryType def = positive.isNone ? root.defaultType : positive;
    return calculateBalance(values, def);
  }

  // TODO: Test this function
  Future<bool> checkBalance(AccountValue value, DateTime at) async {
    final AccountValue balance = await getBalance(at);
    if (positive.isNone) return true;
    if (positive == EntryType.debit) {
      if (value.type == EntryType.credit) {
        if (balance.amount < value.amount) return false;
        return true;
      }
    } else {
      if (value.type == EntryType.debit) {
        if (balance.amount < value.amount) return false;
        return true;
      }
    }
    return true;
  }
}

AccountValue calculateBalance(List<Map<String, Object?>> values, EntryType initialType) {
  AccountValue total = AccountValue(initialType, 0);
  for (final Map<String, Object?> value in values) {
    final AccountValue av = AccountValue(
      EntryType.values[value["type"]! as int],
      value["value"]! as double,
    );
    total += av;
  }
  return total;
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

  bool get isNone => this == EntryType.none;
}

class AccountingEntry implements Document {
  AccountingEntry({
    required this.journalEntry,
    EntryType type = EntryType.none,
    double value = 0,
    this.account,
    this.description = "",
    int createdAt = 0,
    this.action = DocAction.none,
  }):
  id = 0,
  value = AccountValue(type, value),
  createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt),
  name = DateTime.now.hashCode.toString();

  AccountingEntry.map({
    required this.name,
    required this.journalEntry,
    required this.id,
    required double value,
    required EntryType type,
    required this.account,
    required this.description,
    required this.createdAt,
  }): action = DocAction.none, value = AccountValue(type, value);

  AccountingEntry.debit({
    required this.journalEntry,
    this.id = 0,
    double value = 0,
    this.account,
    this.description = "",
    int createdAt = 0,
    this.action = DocAction.none,
  }):
  value = AccountValue(EntryType.debit, value),
  createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt),
  name = DateTime.now.hashCode.toString();

  AccountingEntry.credit({
    required this.journalEntry,
    this.id = 0,
    double value = 0,
    this.account,
    this.description = "",
    int createdAt = 0,
    this.action = DocAction.none,
  }):
  value = AccountValue(EntryType.credit, value),
  createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt),
  name = DateTime.now.hashCode.toString();


  @override
  DocAction action;

  @override
  int id;

  @override
  String name;

  final JournalEntry journalEntry;
  Account? account;
  AccountValue value;
  // EntryType type;
  // double value;
  String description;

  @override
  final DateTime createdAt;

  static String get tableName => "accounting_entries";
  static String get tableQuery => """
  CREATE TABLE $tableName(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    account_id INTEGER,
    journal_entry_id INTEGER,
    description TEXT,
    type INTEGER NOT NULL,
    value REAL NOT NULL,
    FOREIGN KEY(journal_entry_id) REFERENCES ${JournalEntry.tableName}(id) ON DELETE CASCADE
  )""";

  @override
  Future<String?> delete() async {
    if (isNew(this)) return "Accounting Entry:$id delete failed because file is new";
    final bool e = await exist(this, tableName);
    if (!e) return "Accounting Entry:$id delete failed because file does not exist in database";
    final int count = await Core.database!.delete(
      tableName,
      where: "id = ? and journal_entry_id = ?",
      whereArgs: [id, journalEntry.id],
    );
    final bool success = count == 1;
    return success ? null : "Accounting Entry:$name failed to delete from database count:$count";
  }

  @override
  Future<String?> insert() async {
    if (await valuesNotValid()) return "Accounting Entry:$name values not valid";
    if (!isNew(this)) return "Accounting Entry:$name is not new with id of $id";
    if (await exist(this, tableName)) return "Accounting Entry:$name already exist in the database with id of $id";
    final int now = DateTime.now().millisecondsSinceEpoch;

    printInfo("inserting entry with name:$name");
    final Map<String, Object?> values = {
      "name": name,
      "account_id": account!.id,
      "journal_entry_id": journalEntry.id,
      "created_at": now,
      "description": description,
      "type": value.type.value,
      "value": value,
    };
    id = await Core.database!.insert(tableName, values);
    final success = id > 0;
    return success ? null : "Accounting Entry:$name failed to insert to database";
  }

  @override
  Future<String?> update() async {
    if (isNew(this)) return "Accounting Entry:$name is new with id of $id";
    if (await valuesNotValid() ) return "Accounting Entry:$name values is not valid";
    if (!await exist(this, tableName)) return "Accounting Entry:$name does not exist in the database with id of $id";

    final Map<String, Object?> values = {
      "name": name,
      "account_id": account!.id,
      "description": description,
      "type": value.type.value,
      "value": value,
    };

    printWarn("update with values of: ${values.toString()} on entry with id of: $id!");

    final bool success = await Core.database!.update(tableName, values,
      where: "id = ? and journal_entry_id = ?",
      whereArgs: [id, journalEntry.id],
    ) == 1;
    return success ? null : "Accounting Entry:$name failed to update values in the database";
  }

  Future<bool> valuesNotValid() async {
    return (
      account == null ||
      value.type == EntryType.none ||
      value.amount == 0
    );
  }
}

class JournalEntry implements Document {
  JournalEntry(this.profile, {
    required this.entries,
    this.name = "",
    this.id = 0,
    this.action = DocAction.none,
    int createdAt = 0,
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
    created_at INTEGER NOT NULL,
    profile_id INTEGER NOT NULL,
    posted_at INTEGER,
    note TEXT,
    FOREIGN KEY(profile_id) REFERENCES ${Profile.tableName}(id) ON DELETE CASCADE
  ) """;

  @override
  Future<String?> delete() async {
    final bool success = await Core.database!.delete(
      tableName,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) action = DocAction.delete;
    return success ? null : "Journal Entry:$name failed to delete from the database";
  }

  Future<bool> valuesNotValid() async {
    return name.isEmpty;
  }

  @override
  Future<String?> insert() async {
    if (!isNew(this) || await valuesNotValid()) {
      return "Journal Entry:$name is already be in database with id of '$id'";
    }
    final int now = DateTime.now().millisecondsSinceEpoch;
    final Map<String, Object?> values = {
      "name": name,
      "profile_id": profile.id,
      "note": note,
      "created_at": now,
      "posted_at": postedAt.millisecondsSinceEpoch,
    };
    id = await Core.database!.insert(tableName, values);
    final List<AccountingEntry> fails = await insertDocuments(entries);
    final success = id > 0 && fails.isEmpty;
    if (success) {
      action = DocAction.insert;
    } else {
      await Core.database!.delete( tableName, where: "id = ?", whereArgs: [id]);
    }
    return success ? null : "Journal Entry:$name failed to insert to database";
  }

  @override
  Future<String?> update() async {
    if (await valuesNotValid() || isNew(this)) {
      return "Journal Entry:$name values is not valid or document is new";
    }

    final Map<String, Object?> values = {
      "name": name,
      "note": note,
      "posted_at": postedAt.millisecondsSinceEpoch,
    };

    printWarn("update with values of: ${values.toString()} on journal entry with id of: $id!");

    final bool success = await Core.database!.update(tableName, values,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) {
      action = DocAction.update;
      final List<AccountingEntry> fails = await processEntries();
      for (final AccountingEntry fail in fails) {
        printError("failed to process the entry with id of ${fail.id} with action of ${fail.action.toString()}");
      }
      final success = id > 0 && fails.isEmpty;
      if (!success) {
        return "Journal Entry:$name failed to update in ${fails.length} entries:(${fails.join(",")}) in the database";
      }
    }
    return success ? null : "Journal Entry:$name failed to update in database";
  }

  Future<List<AccountingEntry>> processEntries() async {
    final List<AccountingEntry> failed = [];
    printInfo("---processing entries---");
    for (final AccountingEntry entry in entries) {
      printInfo("id:${entry.id}: ${entry.account?.name} -> ${entry.action.toString()}");
      String? error;
      switch (entry.action) {
        case DocAction.delete: {
          error = await entry.delete();
          if (error != null) printError(error);
        } break;
        case DocAction.insert: {
          error = await entry.insert();
          if (error != null) printError(error);
        } break;
        case DocAction.update: {
          error = await entry.update();
          if (error != null) printError(error);
        } break;
        default: break;
      }
      if (error != null) failed.add(entry);
    }
    entries.removeWhere((doc) => doc.action == DocAction.delete);
    return failed;
  }

  Future<void> fetchEntries() async {
    if (id == 0 || entries.isNotEmpty) return;
    final String query = """
    select ae.*,
      a.name as a_name,
      a.created_at as a_created_at,
      a.profile_id as a_profile_id,
      a.is_group as a_is_group,
      a.parent_id as a_parent_id,
      a.root as a_root,
      a.type as a_type
    from ${AccountingEntry.tableName} ae
    join ${Account.tableName} a ON ae.account_id = a.id
    where ae.journal_entry_id = $id
    """;
    final List<Map<String, Object?>> values = await Core.database!.rawQuery(query);
    final List<AccountingEntry> list = [];

    for (var value in values) {
      final DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(value["created_at"]! as int);
      assert(value["a_profile_id"]! as int == profile.id);
      list.add(AccountingEntry.map(
        name: value["name"]! as String,
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
          positive: value["positive"]!,
          root: value["a_root"]!,
          type: value["a_type"]!,
          isGroup: value["a_is_group"]!,
          createdAt: value["created_at"]!,
        ),
      ));
    }
    entries = list;
  }
}
