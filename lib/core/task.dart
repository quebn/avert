import "package:flutter/material.dart";
import "package:avert/core.dart";

enum TaskPriority {
  low,
  moderate,
  important,
}

class Task implements Document {
  Task({
    required this.id,
    required this.createdAt,
    required this.description,
    this.name = "New Task",
    this.dueDate,
    this.priority = TaskPriority.low,
  });

  @override
  int id;
  @override
  String name;
  @override
  DateTime createdAt;

  String description;
  DateTime? dueDate;
  TaskPriority priority;

  static String getTableQuery() => """
    CREATE TABLE tasks(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      createdAt INTEGER NOT NULL,
      description TEXT NOT NULL,
      dueDate INTEGER,
      priority INTEGER NOT NULL,
      createdBy INTEGER NOT NULL
    )
  """;

  @override
  Future<bool> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<bool> insert() {
    // TODO: implement insert
    throw UnimplementedError();
  }

  @override
  Future<bool> update() {
    // TODO: implement update
    throw UnimplementedError();
  }
}
