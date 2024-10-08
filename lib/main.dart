import "package:flutter/material.dart";
import "package:acqua/core.dart";
import "package:acqua/utils.dart";
import "package:sqflite/sqflite.dart";

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: HomePage(title: title)
    );
  }

  _onCreate(Database db, int version) async {
    // Database is created, create the table
    await db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, password TEXT NOT NULL)");
  }

  _onOpen(Database db) async {
    // Database is opened, read from the table
    List<Map<String, Object?>> results = await db.query("users");
    printLog("Printing data from db:\n${results.toString()}", level:LogLevel.warn);
  }

  void initDB() async {
    //Database db = 
    String path = await getDatabasesPath();
    String db = "acqua.db";
    printLog("Databases Path: $path/$db");
    await openDatabase(db,
      version:1,
      onCreate: _onCreate,
      onOpen: _onOpen,
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}
