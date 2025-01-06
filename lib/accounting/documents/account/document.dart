import "package:avert/accounting/utils/common.dart";
import "package:avert/core/components/avert_list_screen.dart";
import "package:avert/core/core.dart";
import "package:avert/core/utils/database.dart";
import "package:avert/core/utils/ui.dart";

import "form.dart";
import "tile.dart";

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
  }) : createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt), children = null;

  Account.group({
    required this.profile,
    required this.root,
    this.id = 0,
    this.name = "",
    this.parentID = 0,
    this.isGroup = true,
    this.type = AccountType.none,
    this.children = const [],
    int createdAt = 0,
  }) : createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt) {
    if (children!.isEmpty) return;
    for (Account child in children!) {
      assert(child.root == root, "Account Root Error: ${child.name}'s root is not the same as parent: $name");
      child.parentID = id;
    }
  }

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

  // TODO: implement
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

  final Profile profile;
  final List<Account>? children;

  AccountRoot root;
  AccountType type;
  bool isGroup;
  int parentID;

  // TODO: implement getTableQuery
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
  Future<Result<Account>> delete() async {
    final bool success =  await Core.database!.delete(tableName,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) return Result<Account>.delete(this);
    return Result<Account>.empty();
  }

  @override
  Future<Result<Account>> insert() async {
    if (!isNew(this) || await valuesNotValid()) {
      printInfo("Document is already be in database with id of '$id'");
      return Result<Account>.empty();
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

    return id == 0 ? Result<Account>.empty() : Result<Account>.insert(this);
  }

  @override
  Future<Result<Account>> update() async {
    if (await valuesNotValid() || isNew(this) || await hasChild) {
      return Result<Account>.empty();
    }

    Map<String, Object?> values = {
      "name": name,
      "root": root.index,
      "type": type.toString(),
      "parent_id": parentID,
      "is_group": isGroup ? 1 : 0,
    };

    printWarn("update with values of: ${values.toString()} on profile with id of: $id!");

    bool success = await Core.database!.update(tableName, values,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;

    return success ? Result<Account>.update(this) : Result<Account>.empty();
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

  static Future<List<Account>> list(Profile profile) async {
    List<Account> list = [];
    List<Map<String, Object?>> values = await Core.database!.query(tableName,
      where: "profile_id = ?",
      whereArgs: [profile.id],
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

  static void listScreen(BuildContext context, Profile profile) async {
    final List<Account> accounts = await list(profile);

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AvertListScreen<Account>(
          title: Text("Accounts"),
          initialList: accounts,
          tileBuilder: (key ,context, account, removeDocument) => AccountTile(
            key: key,
            document: account,
            profile: profile,
            removeDocument: removeDocument,
            //onDelete: () => deleteDocument(),
          ),
          createDocument: (addDocument) async {
            Result<Account> createResult =  await _createAccount(context, profile);
            if (createResult.isEmpty || createResult.action != DocumentAction.insert) return;

            if(!context.mounted) return;
            Result<Account> viewResult = await viewAccount(context, createResult.document!);

            if (!viewResult.isEmpty) {
              if (createResult.isEmpty || createResult.action != DocumentAction.insert) return;
              addDocument(createResult.document!);
              return;
            }

            if (viewResult.action == DocumentAction.update) {
              addDocument(viewResult.document!);
            } else {
              printImplement("SHOULD NOT REACH");
            }
          }
        ),
      ),
    );
  }
}

Future<Result<Account>> _createAccount(BuildContext context, Profile profile) async {
  return await Navigator.of(context).push<Result<Account>>(
    MaterialPageRoute(
      builder: (context) => AccountForm(
        document: Account(profile),
        onSubmit: (d) async {
          String msg = "Error inserting the document to the database!";
          Result<Account> result = await d.insert();

          if (!result.isEmpty) msg = "Account '${d.name}' created!";
          if (context.mounted) notify(context, msg);

          return result;
        },
      ),
    )
  ) ?? Result.empty();
}
