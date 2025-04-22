import "package:avert/docs/accounting.dart";
import "package:avert/docs/document.dart";
import "package:avert/docs/profile.dart";

import "package:avert/ui/account.dart";
import "package:avert/ui/components/list_screen.dart";
import "package:avert/ui/journal_entry.dart";

import "package:avert/utils/database.dart";
import "package:avert/utils/ui.dart";

import "package:flutter/material.dart";
import "package:forui/forui.dart";
import "package:sqflite/sqlite_api.dart";

abstract class Module {
  const Module();

  final Widget icon = const Icon(Icons.question_mark_rounded);
  final String name = "Module";

  Widget dashboardHeader(BuildContext context);
  Widget dashboardBody(BuildContext context);
  List<Widget> documents(BuildContext context, Profile profile);
  Widget reports(BuildContext context);
  Widget settings(BuildContext context);
}


class Core {
  static Database? database;
  static List<Module> modules = [
    Accounting()
  ];
}

class Accounting implements Module {
  @override
  Widget get icon => FIcon(FAssets.icons.handCoins);

  @override
  String get name => "Accounting";

  final List<Account> chartOfAccounts = [];

  bool get isCompleteEmpty {
    return chartOfAccounts.isEmpty;
  }

  @override
  Widget dashboardHeader(BuildContext context) {
    // TODO: check for chart of accounts.
    return SizedBox(
      child: Center(
        child: isCompleteEmpty ? FButton(
          onPress: null,
          label: const Text("Generate Chart of Accounts"),
        ) : null,
      ),
    );
  }

  @override
  Widget dashboardBody(BuildContext context) {
    return SizedBox();
  }

  @override
  List<Widget> documents(BuildContext context, Profile profile) {
    return [
      FTileGroup(
        label: const Text("Master"),
        divider: FTileDivider.full,
        children: [
          FTile(
            onPress: () => listScreenAccount(context, profile),
            // onPress: () => listTileAccounts(context, profile),
            title: const Text("Accounts"),
            prefixIcon: FIcon(FAssets.icons.fileChartColumn),
          ),
          FTile(
            onPress: () => listScreenJE(context, profile),
            title: const Text("Journal Entries"),
            prefixIcon: FIcon(FAssets.icons.file),
          ),
        ],
      ),
    ];
  }

  @override
  Widget reports(BuildContext context) {
    // TODO: implement viewReport
    throw UnimplementedError();
  }

  @override
  Widget settings(BuildContext context) {
    // TODO: implement viewSettings
    throw UnimplementedError();
  }

  Widget companyTab() {
    return SizedBox(
      child: Column(),
    );
  }

  void listScreenAccount(BuildContext context, Profile profile) async {
    final List<Account> accounts = await fetchAccounts(profile);

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
            final Account? account = await createAccount(context, profile);
            if (account == null || account.action != DocAction.insert) return;

            if(!context.mounted) return;
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AccountView(
                  document: account,
                ),
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

  void listScreenJE(BuildContext context, Profile profile) async {
    final List<JournalEntry> accounts = await fetchAllJE(profile);

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AvertListScreen<JournalEntry>(
          title: Text("Journal Entries"),
          initialList: accounts,
          tileBuilder: (key ,context, account, removeDocument) => JournalEntryTile(
            key: key,
            document: account,
            profile: profile,
            removeDocument: removeDocument,
            //onDelete: () => deleteDocument(),
          ),
          createDocument: (addDocument) async {
            final JournalEntry? entry = await createJE(context, profile);
            if (entry == null || entry.action != DocAction.insert) return;

            if(!context.mounted) return;
            await Navigator.of(context).push(
             MaterialPageRoute(
                builder: (context) => JournalEntryView(
                  document: entry
                ),
              )
            );

            if (entry.action == DocAction.insert || entry.action == DocAction.update) {
              addDocument(entry);
            }
          }
        ),
      ),
    );
  }

  Future<Account?> createAccount(BuildContext context, Profile profile) async {
    return await Navigator.of(context).push<Account>(
      MaterialPageRoute(
        builder: (context) {
          final Account document = Account(profile);
          return AccountForm(
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

  Future<JournalEntry?> createJE(BuildContext context, Profile profile) async {
    return await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute(builder: (context) => JournalEntryForm(
        document: JournalEntry(profile),
        onSubmit: (d) async {
          String msg = "Error inserting the document to the database!";
          final bool success = await d.insert();
          if (success) msg = "Account '${d.name}' created!";
          if (context.mounted) notify(context, msg);
          return success;
        },
      )),
    );
  }
}
