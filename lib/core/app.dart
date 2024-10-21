import "package:acqua/core/utils.dart";
import "package:acqua/core/home.dart";
import "package:acqua/core/user.dart";
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
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          surface: Colors.white,
          onSurface: Colors.black,
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.white,
          onSecondary: Colors.black,
          error: Colors.red,
          onError: Colors.white,
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
    printLog("After opening of Database Path:${db?.path}", level:LogLevel.warn);
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
  //batch.execute(App.getTableQuery());
  batch.execute(User.getTableQuery());
  await batch.commit();
}

_onOpen(Database db) async {
  // TODO: onOpen() should do the following:
  //   [x] check if user table is not empty.
  //   [-] check and read the file responsible of storing last user login data.
  //   [-] check if last user exist in user table.
  //   [-] check if user is still valid for skipping authentication.
  //   [-] if yes get user data and skip login screen.

  List<String> cols = ["id", "name", "password", "createdAt"];
  List<Map<String, Object?>> results = await db.query("users", columns: cols);
  if (results.isEmpty) {
    printLog("No users found in users table!", level:LogLevel.error);
  } else {
    printLog("${results.length} user(s) found! with values of ${results.toString()}");
  }
}
