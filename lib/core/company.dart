import "package:flutter/material.dart";
import "package:acqua/core/core.dart";

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
