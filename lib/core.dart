import "package:flutter/material.dart";
export "package:avert/core/app.dart";
export "package:avert/core/task.dart";
export "package:avert/core/user.dart";
export "package:avert/core/company.dart";
export "package:avert/core/utils.dart";

// TODO: Figure out how to test stuffs.
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

  Future<bool> update();
  Future<bool> insert();
  Future<bool> delete();
}

abstract class DocumentView {
  void saveDocument();
  void deleteDocument(BuildContext context);
  Future<void> popDocument(bool didPop, Object? value);
}
