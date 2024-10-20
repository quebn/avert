import "package:acqua/utils.dart";

class User {
  User({
    required this.name, 
    //required this.password, 
    required this.createdAt, 
    required this.lastLoginAt
  });

  String name;
  DateTime createdAt;
  DateTime lastLoginAt;
  
  static String getTableQuery() => """
    CREATE TABLE users(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      password TEXT NOT NULL,
      createdAt INTEGER NOT NULL
    )
    """;
}
