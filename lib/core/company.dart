import "package:flutter/material.dart";
import "package:acqua/core.dart";

// NOTE: should be a document in core.
class Company implements Document {
  Company({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  @override
  int id;

  @override
  String name;

  @override
  DateTime createdAt;

  static String getTableQuery() => """
    CREATE TABLE companies(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      createdAt INTEGER NOT NULL
    )
  """;

  static Future<Company> insert(String name) async {
    DateTime now = DateTime.now();
    Map<String, Object?> values = {
      "name": name,
      "createdAt": now.millisecondsSinceEpoch,
    };
    int id = await App.database!.insert("companies", values);
    printAssert(id != 0, "Insertion Failed to table 'companies' with values of: ${values.toString()}");
    return Company(
      id: id,
      name: name,
      createdAt: now,
    );
  }
  @override
  Widget viewDetails() {
    // TODO: implement details
    throw UnimplementedError();
  }

  @override
  Widget viewList() {
    // TODO: implement details
    throw UnimplementedError();
  }
}
