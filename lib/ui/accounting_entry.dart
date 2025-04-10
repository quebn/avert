import "package:avert/docs/accounting/account.dart";
import "package:avert/docs/accounting/accounting_entry.dart";
import "package:avert/ui/components/document.dart";
import "package:avert/ui/components/select.dart";
import "package:avert/ui/core.dart";
import "package:avert/utils/common.dart";
import "package:flutter/material.dart";

import "package:forui/forui.dart";

class AccountingEntryForm extends StatefulWidget {
  const AccountingEntryForm({super.key,
    required this.document,
    required this.accounts,
  });

  final AccountingEntry document;
  final List<Account> accounts;

  @override
  State<StatefulWidget> createState() => _FormState();
}

class _FormState extends State<AccountingEntryForm> implements DocumentForm {

  AccountingEntry get document => widget.document;
  late final AvertSelectController<Account> _accountSelectController;

  @override
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  String? errMsg;

  @override
  bool isDirty = false;

  @override
  void initState() {
    super.initState();
    _accountSelectController = AvertSelectController<Account>();
  }

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = FTheme.of(context);
    final TextStyle selectValueStyle = theme.textFieldStyle.disabledStyle.labelTextStyle;
    return AvertDocumentForm<AccountingEntry>.dialog(
      formKey: formKey,
      title: Text("${isNew(document) ? "New" : "Edit"} Accounting Entry"),
      isDirty: isDirty,
      contents: [
        AvertSelect<Account>(
          required: true,
          label: "Account",
          valueBuilder: (context, account) {
            return (account != null)
            ? Text(account.name)
            : Text("None", style: selectValueStyle);
          },
          tileSelectBuilder: (context, value) => AvertSelectTile<Account>(
            selected: _accountSelectController.value == value,
            value: value,
            prefix: FIcon(FAssets.icons.fileType),
            title: Text(value.name, style: theme.typography.base),
            subtitle: Text(value.type.toString(), style: theme.typography.sm),
          ),
          options: widget.accounts,
          controller: _accountSelectController
        ),
      ],
    );
  }

  @override
  void onValueChange(bool Function() isDirtyCallback) {
    final bool isReallyDirty = isDirtyCallback();
    if (isReallyDirty == isDirty) return;
    setState(() => isDirty = isReallyDirty );
  }

  @override
  void submitDocument() async {
    final bool isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    FocusScope.of(context).requestFocus(FocusNode());

    document.account = _accountSelectController.value!;

    Navigator.of(context).pop<AccountingEntry>(document);
  }

}
