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
      printInfo("Document is already be in database with id of '$id'");
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
    bool hasDuplicates = await exists(this, tableName);
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
