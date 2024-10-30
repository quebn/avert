import "package:acqua/core/views/login_screen.dart";
import "package:acqua/core/utils.dart";
import "package:acqua/core/views/home_screen.dart";
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
  static bool hasUsers = false;
  static const String storagePath = "/storage/emulated/0/Acqua";
  
  static String getTableQuery() => """
    CREATE TABLE app_settings(
      id INTEGER PRIMARY KEY,
      company TEXT,
      user_id INTEGER
    )
  """;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      //debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          //color: Colors.white,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
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
      home: user == null ? LoginScreen(title:title) : HomeScreen(title: title),
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

  // NOTE: use the directory created as a storage for backup files.
  static Future<bool> createAppDir() async {
    if (!Platform.isAndroid) return false;
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
      "user_id"  : rememberLogin ? userID : null,
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
    "user_id"  : null,
  };
  await db.insert("app_settings", values);
}

_onOpen(Database db) async {
  printLog("Opening Database tables");
  List<Map<String, Object?>> appSettings = await db.query("app_settings", 
    columns: ["company", "user_id"],
    where: "id = ?",
    whereArgs: [1],
  );
  int? userID = appSettings[0]['user_id'] as int?;

  printLog("${appSettings.length} settings found! with values of ${appSettings.toString()}");
  List<Map<String, Object?>> users = await db.query("users", 
    columns: ["id", "name", "createdAt",],// "password", ],
  );
  App.hasUsers = users.isNotEmpty;
  printLog("${users.length} user(s) found! with values of ${users.toString()}");

  if (userID == null || users.isEmpty) { 
    return;
  }
  printAssert(appSettings.isNotEmpty, "Application Settings should not be zero");
  for (var user in users) {
    if (userID == user['id']) {
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(users[0]['createdAt'] as int);
      App.user = User(
        name:users[0]['name'] as String,
        createdAt: dt,
        lastLoginAt: DateTime.now(),
      );
      break;
    }
  }
}
