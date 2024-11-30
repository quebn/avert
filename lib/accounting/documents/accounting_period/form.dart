import "package:avert/core/core.dart";

import "document.dart";

class AccountingPeriodForm extends StatefulWidget {
  const AccountingPeriodForm({super.key,
    required this.document,
  });

  final AccountingPeriod document;

  @override
  State<StatefulWidget> createState() => _FormState();
}

class _FormState extends State<AccountingPeriodForm> implements DocumentForm {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  void initDocumentFields() {
    // TODO: implement initDocumentFields
  }

  @override
  void insertDocument() {
    // TODO: implement insertDocument
  }

  @override
  void updateDocument() {
    // TODO: implement updateDocument
  }
}
