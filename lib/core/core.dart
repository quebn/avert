import "package:flutter/material.dart";
import "package:acqua/core/company.dart";
import "package:acqua/core/user.dart";
export "package:acqua/core/app.dart";
export "package:acqua/core/task.dart";
export "package:acqua/core/user.dart";
export "package:acqua/core/company.dart";

abstract class Module {
  const Module({required this.name});

  final String name;

  Widget viewDashboard();
  Widget viewDocuments();
  Widget viewReport();
  Widget viewSettings();
}

abstract class Document {
  Document({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  int id;
  String name;
  DateTime createdAt;

  Widget viewDetails();
  Widget viewList();
}

class Core implements Module {
  
  @override
  final String name = "Acqua";

  User? user;
  bool hasUsers = false;
  Company? company;
  List<Module> modules = [];

  static String getTableQuery() => """
    CREATE TABLE core_settings(
      id INTEGER PRIMARY KEY,
      company_id TEXT,
      user_id INTEGER
    )
  """;

  @override
  Widget viewDashboard() {
    // TODO: implement viewDashboard
    throw UnimplementedError();
  }

  @override
  Widget viewDocuments() {
    // TODO: implement viewDocuments
    throw UnimplementedError();
  }

  @override
  Widget viewReport() {
    // TODO: implement viewReport
    throw UnimplementedError();
  }

  @override
  Widget viewSettings() {
    // TODO: implement viewSettings
    throw UnimplementedError();
  }

}
