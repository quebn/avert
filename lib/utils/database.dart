import "package:avert/docs/accounting/account.dart";
import "package:avert/docs/accounting/accounting_entry.dart";
import "package:avert/docs/accounting/journal_entry.dart";
import "package:avert/docs/core.dart";
import "package:avert/ui/module.dart";
import "package:avert/docs/profile.dart";
import "package:avert/utils/logger.dart";
import "package:sqflite/sqlite_api.dart";

void createCoreTables(Batch batch) {
  List<String> queries = [
    Profile.tableQuery,
    // Task.getTableQuery() // NOTE: Not planned.
  ];

  for (String query in queries) {
    batch.execute(query);
  }
}

Future<List<Profile>> fetchAllProfile({Database? database}) async {
  List<Map<String, Object?>> values = await (database ?? Core.database!).query(Profile.tableName,
    columns: ["id", "name", "createdAt"],
  );

  List<Profile> list = [];

  if (values.isNotEmpty) {
    for (Map<String, Object?> v in values) {
      list.add(Profile.map(
        id: v["id"]!,
        name: v["name"]!,
        createdAt: v["createdAt"]!,
      ));
    }
  }

  return list;
}

Future<bool> exists(Document document, String table) async {
  List<Map<String, Object?>> values = await Core.database!.query(table,
    columns: ["id"],
    where: "name = ?",
    whereArgs: [document.name],
  );
  return values.isNotEmpty;
}

void createAccountingTables(Batch batch) {
  List<String> queries = [
    Account.tableQuery,
    AccountingEntry.tableQuery,
    JournalEntry.tableQuery
  ];

  for (String query in queries) {
    batch.execute(query);
  }
}

Future<List<Account>> fetchAllAccounts(Profile profile, {bool sorted = false}) async {
  List<Account> list = [];
  List<Map<String, Object?>> values = await Core.database!.query(
    Account.tableName,
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

Future<bool> deleteAllAccounts(Profile profile) async {
  final count = await Core.database!.delete(
    Account.tableName,
    where: "profile_id = ?",
    whereArgs: [profile.id],
  );
  return count > 0;
}

Future<List<JournalEntry>> fetchAllJE(Profile profile, {bool sorted = false}) async {
  List<JournalEntry> list = [];
  List<Map<String, Object?>> values = await Core.database!.query(
    JournalEntry.tableName,
    where: "profile_id = ?",
    whereArgs: [profile.id],
  );

  if (values.isEmpty) return list;

  for (Map<String, Object?> value in values ) {
    printAssert(value["profile_id"] as int == profile.id, "Journal Entry belongs to a different profile.");
    list.add(JournalEntry(
      profile,
      action: DocAction.none,
      id: value["id"]! as int,
      name: value["name"]! as String,
      createdAt: value["createdAt"]! as int,
    ));
  }
  return list;
}
