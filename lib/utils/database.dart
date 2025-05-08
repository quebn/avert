import "package:avert/docs/accounting.dart";
import "package:avert/docs/document.dart";
import "package:avert/ui/module.dart";
import "package:avert/docs/profile.dart";
import "package:avert/utils/logger.dart";
import "package:sqflite/sqlite_api.dart";

void createCoreTables(Batch batch) {
  final List<String> queries = [
    Profile.tableQuery,
  ];
  for (String query in queries) {
    batch.execute(query);
  }
}

Future<List<Profile>> fetchAllProfile({Database? database}) async {
  final List<Map<String, Object?>> values = await (database ?? Core.database!).query(
    Profile.tableName,
    columns: ["id", "name", "created_at"],
  );

  final List<Profile> list = [];

  if (values.isEmpty) return list;

  for (var v in values) {
    list.add(Profile.map(
      id: v["id"]!,
      name: v["name"]!,
      createdAt: v["created_at"]!,
    ));
  }

  return list;
}

Future<bool> exist(Document document, String table) async {
  final List<Map<String, Object?>> values = await Core.database!.query(
    table,
    columns: ["id"],
    where: "id = ?",
    whereArgs: [document.id],
  );
  return values.isNotEmpty;
}

Future<bool> nameExist(Document document, String table) async {
  final List<Map<String, Object?>> values = await Core.database!.query(table,
    columns: ["id"],
    where: "name = ?",
    whereArgs: [document.name],
  );
  return values.isNotEmpty;
}

void createAccountingTables(Batch batch) {
  final List<String> queries = [
    Account.tableQuery,
    AccountingEntry.tableQuery,
    JournalEntry.tableQuery
  ];

  for (String query in queries) {
    batch.execute(query);
  }
}

Future<List<Account>> fetchAccounts(Profile profile, {String? where, List<Object>? whereArgs, String? orderBy}) async {
  final List<Account> list = [];
  final String w = where ?? "profile_id = ?";
  final List<Object> wa = whereArgs ?? [profile.id];
  final List<Map<String, Object?>> values = await Core.database!.query(
    Account.tableName,
    where: w,
    whereArgs: wa,
    orderBy: orderBy,
  );

  if (values.isEmpty) return list;

  profile.mapAccountsToList(list, values);
  return list;
}

Future<List<JournalEntry>> fetchJournalEntries(Profile profile, {bool sorted = false}) async {
  final List<JournalEntry> list = [];
  final List<Map<String, Object?>> values = await Core.database!.query(
    JournalEntry.tableName,
    where: "profile_id = ?",
    whereArgs: [profile.id],
  );

  // printInfo(result.toString());
  printInfo(values.toString());

  if (values.isEmpty) return list;

  for (var value in values) {
    printAssert(value["profile_id"] as int == profile.id, "Journal Entry belongs to a different profile.");
    final DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(value["created_at"]! as int);
    final DateTime postedAt = DateTime.fromMillisecondsSinceEpoch(value["posted_at"]! as int);
    list.add(JournalEntry.map(
      profile,
      action: DocAction.none,
      name: value["name"]! as String,
      id: value["id"]! as int,
      note: value["note"]! as String,
      entries: [

      ],
      createdAt: createdAt,
      postedAt: postedAt
    ));
  }
  return list;
}

void logTable(String tablename, List<String>? columns, {String? where, List<Object>? whereArgs}) async {
  final List<Map<String, Object?>> values = await Core.database!.query(
    tablename,
    columns: columns,
    where: where,
    whereArgs: whereArgs
  );
  printInfo(values.toString());
}

Future<List<T>> insertDocuments<T extends Document>(List<T> documents) async {
  final List<T> failed = [];
  for (T documents in documents) {
    final String? error = await documents.insert();
    if (error != null) failed.add(documents);
  }
  return failed;
}

Future<List<T>> updateDocuments<T extends Document>(List<T> documents) async {
  final List<T> failed = [];
  for (T documents in documents) {
    final String? error = await documents.update();
    if (error != null) failed.add(documents);
  }
  return failed;
}

List<Account> defaultAccounts(Profile profile) => [
    Account.asset(
      profile: profile,
      name: "Asset",
      children: [
        Account.asset(
          profile: profile,
          name: "Bank",
          type: AccountType.bank,
        ),
        Account.asset(
          profile: profile,
          name: "Cash on Hand",
          type: AccountType.cash,
        ),
      ]
    ),
    Account.liability(
      profile: profile,
      name: "Liability",
      children: [
        Account.liability(
          profile: profile,
          name: "Accounts Payable",
          type: AccountType.payable,
        )
      ]
    ),
    Account.equity(
      profile: profile,
      name: "Equity",
      children: [
        Account.equity(
          profile: profile,
          name: "Common Stock",
        ),
        Account.equity(
          profile: profile,
          name: "Retained Earnings",
        ),
      ]
    ),
    Account.income(
      profile: profile,
      name: "Income",
      children: [
        Account.income(
          profile: profile,
          name: "Sales",
        ),
        Account.income(
          profile: profile,
          name: "Discount",
          positive: EntryType.debit
        ),
      ]
    ),
    Account.expense(
      profile: profile,
      name: "Expense",
      children: [
        Account.expense(
          profile: profile,
          name: "Maintenance Expense",
          positive: EntryType.none,
        ),
        Account.expense(
          profile: profile,
          name: "Cost of Goods Sold",
          type: AccountType.cogs,
          positive: EntryType.none,
        ),
      ]
    ),
];

Future<void> genTestDocs(Profile profile) async {
  final List<Account> accounts = defaultAccounts(profile);
  for (Account account in accounts) {
    final String? err = await account.insert();
    printAssert(err == null, err ?? "Test Account insert failed");
  }
}
