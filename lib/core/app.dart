import "package:flutter/material.dart";
import "package:acqua/core/views/login_screen.dart";
import "package:acqua/core/views/home_screen.dart";
import "package:acqua/core.dart";
import "package:sqflite/sqflite.dart";
import "package:permission_handler/permission_handler.dart";
import "dart:io";

class App extends StatelessWidget{
  const App({super.key});

  final String title = "Acqua";

  // TODO: let utils handle the access and write of these static data.
  static Database? database;
  static bool hasUsers = false;
  static User? user;
  static Company? company;
  
  static String getTableQuery() => """
    CREATE TABLE app_settings(
      id INTEGER PRIMARY KEY,
      company_id TEXT,
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
    database = await openDatabase(dbFile,
      version: 1,
      onCreate: _onCreate,
      onOpen: _onOpen,
    );
    printLog("After opening of Database Path:${database?.path}", level:LogLevel.warn);
  }

  // NOTE: use the directory created as a storage for backup files.
  static Future<bool> createAppDir() async {
    if (!Platform.isAndroid) {
      return false;
    }
    const String path = "/storage/emulated/0/Acqua";
    var status = await Permission.manageExternalStorage.request();
    if (status.isDenied) {
      printLog("Storage access permission denied!", level: LogLevel.error);
    } else {
      printLog("Storage access permission granted!");
    }
    Directory dir = await Directory(path).create(recursive: true);
    printLog("Acqua Directory path: ${dir.path} uri: ${dir.uri}", level:LogLevel.warn);
    return status.isDenied;
  }

  static Future<void> rememberUser(int userID, bool rememberLogin) async {
    Map<String, dynamic> values = {
      "user_id"  : rememberLogin ? userID : null,
    };
    await database!.update("app_settings", values,
      where: "id = ?",
      whereArgs: [1],
    );
  }

  static Future<void> rememberCompany(int companyID) async {
    Map<String, dynamic> values = {
      "company_id"  : companyID,
    };
    await database!.update("app_settings", values,
      where: "id = ?",
      whereArgs: [1],
    );
  }
  
  static Future<void> initCompany(Database db) async {
    List<Map<String, Object?>> companies = await db.query("companies", 
      columns: ["id", "name", "createdAt",],
      orderBy: "id ASC",
      limit: 1,
    );
    if (companies.isNotEmpty) {
      App.company = Company(
        id: companies[0]['id'] as int,
        name: companies[0]['name'] as String,
        createdAt: companies[0]['createdAt'] as int,
      );
    }
    printLog("${companies.length} companies found! with values of ${companies.toString()}");
  }
}

_onCreate(Database db, int version) async {
  printLog("Creating Database tables");
  Batch batch = db.batch();
  batch.execute(App.getTableQuery());
  batch.execute(User.getTableQuery());
  batch.execute(Company.getTableQuery());
  batch.execute(Task.getTableQuery());
  await batch.commit();
  Map<String, dynamic> values = {
    "company_id"   : null,
    "user_id"  : null,
  };
  await db.insert("app_settings", values);
}

_onOpen(Database db) async {
  printLog("Opening Database tables");
  List<Map<String, Object?>> appSettings = await db.query("app_settings", 
    columns: ["company_id", "user_id"],
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
  if (appSettings[0]['company_id'] != null) {
    List<Map<String, Object?>> companies = await db.query("companies", 
      columns: ["id", "name", "createdAt",],
      where: "id = ?",
      whereArgs: [appSettings[0]['company_id']],
    );
    if (companies.isNotEmpty) {
      App.company = Company(
        id: companies[0]['id'] as int,
        name: companies[0]['name'] as String,
        createdAt: companies[0]['createdAt'] as int,
      );
    }
  }
  if (App.company == null) {
    await App.initCompany(db);
  }

  if (userID == null || users.isEmpty) { 
    return;
  }
  printAssert(appSettings.isNotEmpty, "Application Settings should not be zero");
  for (Map<String, Object?> user in users) {
    if (userID == user['id']) {
      User.login(
        id: user['id']!,
        name: user['name']!,
        createdAt: user['createdAt']!,
      );
      break;
    }
  }
}
