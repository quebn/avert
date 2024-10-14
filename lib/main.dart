import "package:flutter/material.dart";
import "package:acqua/core.dart";
import "package:acqua/utils.dart";
import "package:sqflite/sqflite.dart";
import "package:crypto/crypto.dart";
import "dart:convert";

class App extends StatelessWidget{
  const App({super.key});

  final String title = "Acqua";
  static User? currentUser;

  @override
  Widget build(BuildContext context) {
    initDB();
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

  _onCreate(Database db, int version) async {
    // Database is created, create the table
    String query = """CREATE TABLE users(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      password TEXT NOT NULL,
      createdAt INTEGER NOT NULL,
      lastLoginAt INTEGER NOT NULL,
      createdBy INTEGER NOT NULL 
    )""";
    await db.execute(query);
  }

  _onOpen(Database db) async {
    // Database is opened, read from the table
    String username = "Administrator";
    List<Map<String, Object?>> results = await db.query("users",
      columns: ["id", "name", "password"],
      where: "name = ?",
      whereArgs: [username]
    );

    if (results.isEmpty) {
      printLog("No user found with username of: \"$username\"!", level:LogLevel.error);
    }
  }

  Future<Database> initDB() async {
    String dbPath = await getDatabasesPath();
    String dbFile = "acqua.db";

    printLog("Databases Path: $dbPath/$dbFile");
    Database db = await openDatabase(dbFile,
      version:1,
      onCreate: _onCreate,
      onOpen: _onOpen,
    );
    printLog("After opening of Database Path:${db.path}", level:LogLevel.warn);
    return db;
  }

  Digest hash(String text) {
    var bytes = utf8.encode(text);
    return sha256.convert(bytes);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}
