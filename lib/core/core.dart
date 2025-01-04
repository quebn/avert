//import "package:avert/core/documents/company/document.dart";
import "package:avert/accounting/accounting.dart";
import "package:avert/core/documents/profile/document.dart";
import "package:flutter/material.dart";
import "package:sqflite/sqflite.dart";


export "package:avert/core/documents/profile/document.dart";
export "package:flutter/material.dart";
export "package:sqflite/sqflite.dart";
export "package:avert/core/utils/logger.dart";
export "package:avert/core/utils/common.dart";

// TODO: Figure out how to test stuffs.
abstract class Module {
  const Module();

  final Widget icon = const Icon(Icons.question_mark_rounded);
  final String name = "Module";

  Widget dashboardHeader(BuildContext context);
  Widget dashboardBody(BuildContext context);
  List<Widget> documents(BuildContext context, Profile profile);
  Widget reports(BuildContext context);
  Widget settings(BuildContext context);
}

enum DocumentAction {
  none,
  insert,
  update,
  delete,
}

// TODO: use this struct as result to be returned in Navigator.of(context) functions.
class DocumentResult<T extends Document> {
  const DocumentResult(this.document):action = DocumentAction.none;
  const DocumentResult.insert(this.document):action = DocumentAction.insert;
  const DocumentResult.update(this.document):action = DocumentAction.update;
  const DocumentResult.delete(this.document):action = DocumentAction.delete;

  final T document;
  final DocumentAction action;
}

abstract class Document {
  Document({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  int id;
  String name;
  final DateTime createdAt;

  // TODO: make insert return a message on success and failure.
  Future<bool> update();
  Future<bool> insert();
  Future<bool> delete();
}

abstract class DocumentView<T extends Document> {
  Future<void> deleteDocument();
  void editDocument();
  late T document;
  bool edited = false;
}

abstract class DocumentForm {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};

  bool isDirty = false;
  String? errMsg;

  void onValueChange(bool Function() isDirtyCallback);
  void submitDocument();
}

class Core {
  static Database? database;
  static List<Module> modules = [
    Accounting()
  ];
}
