import "package:acqua/utils.dart";

class User {
  User({
    required this.name, 
    //required this.password, 
    required this.createdAt, 
    required this.lastLoginAt
  });

  String name;
  //String password;
  DateTime createdAt;
  //DateTime modifiedAt;
  DateTime lastLoginAt;
  
  static const String createTableQuery = """
    CREATE TABLE IF NOT EXIST users(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      password TEXT NOT NULL,
      createdAt INTEGER NOT NULL,
      createdBy INTEGER NOT NULL,
      lastLoginAt INTEGER
    )""";
}
