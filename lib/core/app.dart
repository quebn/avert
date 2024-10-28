import "package:acqua/core/login/login_page.dart";
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
  static User? user;
  static const String storagePath = "/storage/emulated/0/Acqua";
  
  // TODO: 'user' column should be 'user_id'.
  static String getTableQuery() => """
    CREATE TABLE app_settings(
      id INTEGER PRIMARY KEY,
      company TEXT,
      user INTEGER
    )
  """;

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
      home: user == null ? LoginPage(title:title) : HomePage(title: title),
    );
  }
  
  static Future<void> initDB({bool isDenied = false}) async {
    final String dbPath = await getDatabasesPath();
    //appDir
    final String dbFile = "acqua.db";
    printLog("Databases Path: $dbPath/$dbFile");
    db = await openDatabase(dbFile,
      version: 1,
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

  static Future<void> rememberUser(int userID, bool rememberLogin) async {
    Map<String, dynamic> values = {
      "user"  : rememberLogin ? userID : null,
    };
    await db!.update("app_settings", values,
      where: "id = ?",
      whereArgs: [1],
    );
  }
}

_onCreate(Database db, int version) async {
  printLog("Creating Database tables");
  Batch batch = db.batch();
  batch.execute(App.getTableQuery());
  batch.execute(User.getTableQuery());
  await batch.commit();
  Map<String, dynamic> values = {
    "company"   : null,
    "user"  : null,
  };
  await db.insert("app_settings", values);
}

_onOpen(Database db) async {
  printLog("Opening Database tables");
  // TODO: onOpen() should do the following:
  //   [x] check if user table is not empty.
  //   [-] check and read the file responsible of storing last user login data.
  //   [-] check if last user exist in user table.
  //   [-] check if user is still valid for skipping authentication.
  //   [-] if yes get user data and skip login screen.


  List<Map<String, Object?>> appSettings = await db.query("app_settings", 
    columns: ["company", "user"],
    where: "id = ?",
    whereArgs: [1],
  );
  printLog("${appSettings.length} settings found! with values of ${appSettings.toString()}");
  int? userID = appSettings[0]['user'] as int?;
  if (userID == null) { 
    printLog("userID: $userID ", level:LogLevel.error);
    return;
  }
  List<Map<String, Object?>> users = await db.query("users", 
    columns: ["id", "name", "createdAt",],// "password", ],
    where: "id = ?",
    whereArgs: [userID],
  );
  printAssert(appSettings.isNotEmpty, "Application Settings should not be zero");
  if (users.isEmpty) {
    printLog("${users.length} user(s)", level:LogLevel.error);
    return;
  }
  printLog("${users.length} user(s) found! with values of ${users.toString()}");
  DateTime dt = DateTime.fromMillisecondsSinceEpoch(users[0]['createdAt'] as int);
  App.user = User(
    name:users[0]['name'] as String,
    createdAt: dt,
    lastLoginAt: DateTime.now(),
  );
}
