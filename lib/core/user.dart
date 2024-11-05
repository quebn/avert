import "package:flutter/material.dart";
import "package:acqua/core/utils.dart";
import "package:acqua/core.dart";
import "package:sqflite/sqflite.dart";

class User implements Document {
  User({
    required this.id, 
    required this.name, 
    required this.createdAt, 
  });

  User.login({
    required Object id, 
    required Object name, 
    required Object createdAt, 
  }):
    id = id as int,
    name = name as String,
    createdAt =  DateTime.fromMillisecondsSinceEpoch(createdAt as int)
  {
    App.user = this;
  }

  @override
  int id;

  @override
  String name;

  @override
  DateTime createdAt;

  
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
