import "package:avert/core/core.dart";

enum AccountRoot {
  asset,
  liability,
  equity,
  income,
  expense,
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
  investment,
}

class Account implements Document {
  Account({
    required this.root,
    required this.company,
    this.id = 0,
    this.name = "",
    this.parent,
    this.type = AccountType.none,
    int createdAt = 0,
  }) : createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt), children = null;

  Account.parent({
    required this.root,
    required this.company,
    this.id = 0,
    this.name = "",
    this.parent,
    this.type = AccountType.none,
    this.children = const [],
    int createdAt = 0,
  }) : createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt) {
    if (children!.isEmpty) return;
    for (Account child in children!) {
      assert(child.root == root, "Account Root Error: ${child.name}'s root is not the same as parent: $name");
      child.parent = this;
    }
  }

  Account.asset({
    required Company company,
    int id = 0,
    String name = "",
    Account? parent,
    AccountType type = AccountType.none,
  }) : this(
    id: id,
    company: company,
    name: name,
    parent: parent,
    type: type,
    root: AccountRoot.asset
  );

  Account.liability({
    required Company company,
    int id = 0,
    String name = "",
    Account? parent,
    AccountType type =  AccountType.none,
  }) : this(
    id: id,
    company: company,
    name: name,
    parent: parent,
    type: type,
    root: AccountRoot.liability
  );

  Account.equity({
    required Company company,
    int id = 0,
    String name = "",
    Account? parent,
    AccountType type =  AccountType.none,
  }) : this(
    id: id,
    company: company,
    name: name,
    parent: parent,
    type: type,
    root: AccountRoot.equity
  );

  Account.income({
    required Company company,
    int id = 0,
    String name = "",
    Account? parent,
    AccountType type =  AccountType.none,
  }) : this(
    id: id,
    company: company,
    name: name,
    parent: parent,
    type: type,
    root: AccountRoot.income
  );

  Account.expense({
    required Company company,
    int id = 0,
    String name = "",
    Account? parent,
    AccountType type =  AccountType.none,
  }) : this(
    id: id,
    company: company,
    name: name,
    parent: parent,
    type: type,
    root: AccountRoot.expense
  );

  @override
  int id;

  @override
  String name;

  @override
  final DateTime createdAt;

  final Company company;
  final AccountRoot root;
  final AccountType type;
  final List<Account>? children;
  Account? parent;

  // TODO: implement getTableQuery
  static String get getTableQuery => throw UnimplementedError();
  //"""
  //  CREATE TABLE accounts(
  //    id INTEGER PRIMARY KEY,
  //    name TEXT NOT NULL,
  //    createdAt INTEGER NOT NULL,
  //    type INTEGER NOT NULL
  //  )
  //""";

  @override
  Future<bool> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<bool> insert() {
    // TODO: implement insert
    throw UnimplementedError();
  }

  @override
  Future<bool> update() {
    // TODO: implement update
    throw UnimplementedError();
  }
}
