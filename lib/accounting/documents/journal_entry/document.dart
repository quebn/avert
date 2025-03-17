import 'package:avert/accounting/documents/accounting_entry/document.dart';
import 'package:avert/core/components/list_screen.dart';
import 'package:avert/core/core.dart';
import 'package:avert/core/utils/database.dart';
import 'package:avert/core/utils/ui.dart';

import 'form.dart';
import 'tile.dart';

class JournalEntry implements Document {
  JournalEntry(this.profile, {
    this.name = "",
    this.id = 0,
    this.action = DocAction.none,
    int createdAt = 0,
    this.entries = const [],
    this.postedAt,
  }) : createdAt = DateTime.fromMillisecondsSinceEpoch(createdAt);

  @override
  DocAction action;

  @override
  int id;

  @override
  String name;

  @override
  DateTime createdAt;

  DateTime? postedAt;
  List<AccountingEntry> entries;
  Profile profile;

  static String get tableName => "journal_entries";
  static String get tableQuery => """ CREATE TABLE $tableName(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    createdAt INTEGER NOT NULL,
    profile_id INTEGER NOT NULL,
    postedAt INTEGER
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
      "createdAt": now,
      "postedAt": postedAt?.millisecondsSinceEpoch ?? 0,
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
      "postedAt": postedAt?.millisecondsSinceEpoch ?? 0,
    };

    printWarn("update with values of: ${values.toString()} on journal entry with id of: $id!");

    bool success = await Core.database!.update(tableName, values,
      where: "id = ?",
      whereArgs: [id],
    ) == 1;
    if (success) action = DocAction.update;
    return success;
  }

  static Future<List<JournalEntry>> fetchAll(Profile profile, {bool sorted = false}) async {
    List<JournalEntry> list = [];
    List<Map<String, Object?>> values = await Core.database!.query(tableName,
      where: "profile_id = ?",
      whereArgs: [profile.id],
    );

    if (values.isEmpty) return list;

    for (Map<String, Object?> value in values ) {
      printAssert(value["profile_id"] as int == profile.id, "Account belongs to a different profile.");
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


  static void listScreen(BuildContext context, Profile profile) async {
    final List<JournalEntry> accounts = await fetchAll(profile);

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AvertListScreen<JournalEntry>(
          title: Text("Accounts"),
          initialList: accounts,
          tileBuilder: (key ,context, account, removeDocument) => JournalEntryTile(
            key: key,
            document: account,
            profile: profile,
            removeDocument: removeDocument,
            //onDelete: () => deleteDocument(),
          ),
          createDocument: (addDocument) async {
            final JournalEntry? account = await _createAccount(context, profile);
            if (account == null || account.action != DocAction.insert) return;

            if(!context.mounted) return;
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => throw UnimplementedError(),
              )
            );

            if (account.action == DocAction.insert || account.action == DocAction.update) {
              addDocument(account);
            }
          }
        ),
      ),
    );
  }

}

Future<JournalEntry?> _createAccount(BuildContext context, Profile profile) async {
  return await Navigator.of(context).push<JournalEntry>(
    MaterialPageRoute(
      builder: (context) {
        final JournalEntry document = JournalEntry(profile);
        return JournalEntryForm(
          document: document,
          onSubmit: (d) async {
            String msg = "Error inserting the document to the database!";
            final bool success = await d.insert();

            if (success) msg = "Account '${d.name}' created!";
            if (context.mounted) notify(context, msg);
            return success;
          },
        );
      },
    )
  );
}
