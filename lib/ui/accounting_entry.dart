import "package:avert/docs/accounting/accounting_entry.dart";
import "package:avert/ui/core.dart";
import "package:flutter/material.dart";

class AccountingEntryForm extends StatefulWidget {
  const AccountingEntryForm({super.key,
    required this.document,
    required this.onSubmit,
  });

  final AccountingEntry document;
  final Future<bool> Function(AccountingEntry) onSubmit;

  @override
  State<StatefulWidget> createState() => _FormState();
}

class _FormState extends State<AccountingEntryForm> implements DocumentForm {
  @override
  String? errMsg;

  @override
  bool isDirty = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  // TODO: implement controllers
  Map<String, TextEditingController> get controllers => throw UnimplementedError();

  @override
  // TODO: implement formKey
  GlobalKey<FormState> get formKey => throw UnimplementedError();

  @override
  void onValueChange(bool Function() isDirtyCallback) {
    // TODO: implement onValueChange
  }

  @override
  void submitDocument() {
    // TODO: implement submitDocument
  }

}
