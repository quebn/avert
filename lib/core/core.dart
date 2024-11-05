import "package:flutter/material.dart";
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
