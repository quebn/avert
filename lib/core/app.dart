import "package:acqua/core.dart";
import "package:acqua/utils.dart";
import "package:flutter/material.dart";
import "package:sqflite/sqflite.dart";
import "package:permission_handler/permission_handler.dart";
import "dart:io";

class App extends StatelessWidget{
  const App({super.key});

  final String title = "Acqua";
  static Database? db;
  static const String storagePath = "/storage/emulated/0/Acqua";
  //static User? currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          primary: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: HomePage(title: title)
    );
  }
  
  static Future<void> dbInit({bool isDenied = false}) async {
    String dbPath = await getDatabasesPath();
    String dbFile = "acqua.db";

    printLog("Databases Path: $dbPath/$dbFile");
    db = await openDatabase(dbFile,
      version:1,
      onCreate: _onCreate,
      onOpen: _onOpen,
    );
  }

  static Future<bool> createAppDir() async {
    // NOTE: use the directory created as a storage for backup files.
    var status = await Permission.manageExternalStorage.request();

    if (status.isDenied) {
      printLog("Storage access permission denied!", level: LogLevel.error);
    } else {
      printLog("Storage access permission granted!");
    }

    Directory dir = await Directory(App.storagePath).create(recursive: true);
    printLog("Acqua Directory path: ${dir.path} uri: ${dir.uri}", level:LogLevel.warn);
    return status.isDenied;
  }
}


_onCreate(Database db, int version) async {
  Batch batch = db.batch();
  batch.execute(User.createTableQuery);

  //List<dynamic> res = await batch.commit();
  await batch.commit();
  
}

_onOpen(Database db) async {
  String username = "Administrator";
  List<Map<String, Object?>> results = await db.query("users",
    columns: ["id", "name", "password", "createdAt", "createdBy", "lastLoginAt"],
    where: "name = ?",
    whereArgs: [username]
  );

  if (results.isEmpty) {
    printLog("No user found with username of: \"$username\"!", level:LogLevel.error);
  } else {
    printLog("username with value of \"$username\" found! with values of ${results.toString()}");
  }
}
