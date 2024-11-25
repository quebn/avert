import "package:flutter/material.dart";
import "package:sqflite/sqflite.dart";

export "package:flutter/material.dart";
export "package:sqflite/sqflite.dart";
export "package:avert/core/documents/task/document.dart";
export "package:avert/core/documents/user/document.dart";
export "package:avert/core/documents/company/document.dart";
export "package:avert/core/utils/logger.dart";
export "package:avert/core/utils/common.dart";

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

  // TODO: make insert return a message on success and failure.
  Future<bool> update();
  Future<bool> insert();
  Future<bool> delete();
}

abstract class DocumentView {
  void initDocumentFields();
  void updateDocument();
  Future<void> deleteDocument();
}

abstract class DocumentNew {
  void initDocumentFields();
  void insertDocument();
}

class Core {
  static Database? database;
}
