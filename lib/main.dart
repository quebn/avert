import "package:avert/docs/accounting.dart";
import "package:avert/ui/module.dart";
import "package:avert/docs/profile.dart";

import "package:avert/ui/greeter.dart";

import "package:avert/utils/logger.dart";
import "package:avert/utils/database.dart";

import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";
import "package:forui/theme.dart";
import "package:sqflite/sqflite.dart";

import "dart:io";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<Profile> profiles = [];
  Core.database = await openDatabase(
    "avert.db",
    version: 1,
    onCreate: onCreate,
    onConfigure: (db) async {
      await db.execute("PRAGMA foreign_keys = ON");
    },
    onOpen: (db) async {
      await onOpen(db);
      profiles = await fetchAllProfile(database: db);
    }
  );
  printInfo("Database Path:${Core.database!.path}");
  runApp(App(title: "Avert", profiles: profiles));
}

class App extends StatelessWidget {
  const App({super.key,
    required this.title,
    required this.profiles,
  });

  final String title;
  final List<Profile> profiles;

  @override
  Widget build(BuildContext context) {
    createAppDir();
    return FTheme(
      data: FThemes.zinc.dark,
      child: MaterialApp(
        themeMode: ThemeMode.system,
        title: title,
        home:  GreeterScreen(
          title: title,
          profiles: profiles,
          initialProfile: profiles.isNotEmpty ? profiles[0] : null,
        ),
      ),
    );
  }
}

Future<bool> createAppDir() async {
  if (!Platform.isAndroid) {
    return false;
  }
  const String path = "/storage/emulated/0/Avert";
  var status = await Permission.manageExternalStorage.request();
  if (status.isDenied) {
    printError("Storage access permission denied!");
  } else {
    printInfo("Storage access permission granted!");
  }
  Directory dir = await Directory(path).create(recursive: true);
  printWarn("Avert Directory path: ${dir.path} uri: ${dir.uri}");
  return status.isDenied;
}

void onCreate(Database db, int version) async {
  Batch batch = db.batch();

  createCoreTables(batch);
  createAccountingTables(batch);

  await batch.commit();
}

Future<void> onOpen(Database db) async {
  List<Map<String, Object?>> profiles = await db.query(Profile.tableName);
  for (var profile in profiles) {
    printTrack(profile.toString());
    List<Map<String, Object?>> accounts = await db.query(
      Account.tableName,
      where: "profile_id = ?",
      whereArgs: [profile["id"]! as int],
    );
    printSuccess(accounts.toString());
  }
}
