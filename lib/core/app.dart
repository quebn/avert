import "package:acqua/core.dart";
import "package:acqua/utils.dart";
import "package:flutter/material.dart";
import "package:sqflite/sqflite.dart";

class App extends StatelessWidget{
  const App({super.key});

  final String title = "Acqua";
  static Database? db;
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
  
  static Future<void> dbInit() async {
    String dbPath = await getDatabasesPath();
    String dbFile = "acqua.db";

    printLog("Databases Path: $dbPath/$dbFile");
    db = await openDatabase(dbFile,
      version:1,
      onCreate: _onCreate,
      onOpen: _onOpen,
    );
  }
}


_onCreate(Database db, int version) async {
  // Database is created, create the table
  String query = """CREATE TABLE users(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    password TEXT NOT NULL,
    createdAt INTEGER NOT NULL,
    createdBy INTEGER NOT NULL,
    lastLoginAt INTEGER
    )""";
  await db.execute(query);
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
