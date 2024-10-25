import "package:acqua/core/utils.dart";

class User {
  User({
    required this.name, 
    required this.createdAt, 
    required this.lastLoginAt
  });

  String name;
  DateTime createdAt;
  DateTime lastLoginAt;
  
  void save(String password) {

  }

  static String getTableQuery() => """
    CREATE TABLE users(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      password TEXT NOT NULL,
      createdAt INTEGER NOT NULL
    )
  """;
  
  static User? getUser() {
    User? user;

    return user;
  }

}
