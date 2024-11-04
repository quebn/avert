import "package:flutter/material.dart";
import "package:acqua/core/utils.dart";
import "package:acqua/core/core.dart";

class User implements Document {
  User({
    required this.id, 
    required this.name, 
    required this.createdAt, 
    required this.lastLoginAt
  });

  @override
  int id;

  @override
  String name;

  @override
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
  
  @override
  Widget viewDetails() {
    // TODO: implement viewDetails
    throw UnimplementedError();
  }

  @override
  Widget viewList() {
    // TODO: implement viewList
    throw UnimplementedError();
  }
}
