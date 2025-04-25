import "package:avert/docs/document.dart";
import "package:flutter/widgets.dart";

abstract class DocumentForm {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isDirty = false;
  String? errMsg;

  void submitDocument();
}

abstract class DocumentView<T extends Document> {
  Future<void> deleteDocument();
  void editDocument();
  T get document;
}
