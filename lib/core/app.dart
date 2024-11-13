import "package:flutter/material.dart";
import "package:avert/core/views/login_screen.dart";
import "package:avert/core/views/home_screen.dart";
import "package:avert/core.dart";
import "package:sqflite/sqflite.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:permission_handler/permission_handler.dart";
import "dart:io";

class App extends StatelessWidget {
  const App({super.key});

  final String title = "Avert";

  // TODO: let utils handle the access and write of these static data.
  static Database? database;
  static bool hasUsers = false;
  static User? user;
  static Company? company;
  
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
    final String dbFile = "avert.db";
    database = await openDatabase(dbFile,
      version: 1,
      onCreate: _onCreate,
      onOpen: _onOpen,
    );
    printDebug("After opening of Database Path:${database?.path}", level:LogLevel.warn);
  }

  // NOTE: use the directory created as a storage for backup files.
  static Future<bool> createAppDir() async {
    if (!Platform.isAndroid) {
      return false;
    }
    const String path = "/storage/emulated/0/Avert";
    var status = await Permission.manageExternalStorage.request();
    if (status.isDenied) {
      printDebug("Storage access permission denied!", level: LogLevel.error);
    } else {
      printDebug("Storage access permission granted!");
    }
    Directory dir = await Directory(path).create(recursive: true);
    printDebug("Avert Directory path: ${dir.path} uri: ${dir.uri}", level:LogLevel.warn);
    return status.isDenied;
  }

  static void rememberUser(int userID, bool rememberLogin) {
    final SharedPreferencesAsync cachedPrefs = SharedPreferencesAsync();
    cachedPrefs.setInt("user_id", userID).then((r) {
      printDebug("user_id set with value of: $userID");
    });
  }

  static void rememberCompany(int companyID) {
    final SharedPreferencesAsync cachedPrefs = SharedPreferencesAsync();
    cachedPrefs.setInt("company_id", companyID).then((r) {
      printDebug("company_id set with values of: $companyID");
    });
  }
  
  static Future<void> loadCompany(int companyID, Database db) async {
    List<Map<String, Object?>> companies = [];
    List<String> cols = ["id", "name", "createdAt",];
    if (companyID > 0) {
      companies = await db.query("companies", 
        columns: cols,
        where: "id = ?",
        whereArgs: [companyID],
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
      companies = await db.query("companies", 
        columns: cols,
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
    }
    printDebug("${companies.length} companies found! with values of ${companies.toString()}");
  }
}

_onCreate(Database db, int version) async {
  printDebug("Creating Database tables");
  Batch batch = db.batch();
  batch.execute(User.getTableQuery());
  batch.execute(Company.getTableQuery());
  batch.execute(Task.getTableQuery());
  //batch.execute(Accounting.getTableQuery()):
  await batch.commit();
}

_onOpen(Database db) async {
  printDebug("Opening Database tables");
  final SharedPreferencesWithCache cachedPrefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: <String>{"user_id", "company_id"},
    )
  );
  int userID = cachedPrefs.getInt("user_id") ?? 0;

  List<Map<String, Object?>> users = await db.query("users", 
    columns: ["id", "name", "createdAt",],// "password", ],
  );
  App.hasUsers = users.isNotEmpty;
  printDebug("${users.length} user(s) found! with values of ${users.toString()}");

  int companyID = cachedPrefs.getInt("company_id") ?? 0;
  await App.loadCompany(companyID, db);

  if (userID == 0 || users.isEmpty) { 
    return;
  }
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


