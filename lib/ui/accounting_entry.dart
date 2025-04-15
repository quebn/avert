import "package:avert/docs/accounting/account.dart";
import "package:avert/docs/accounting/accounting_entry.dart";
import "package:avert/docs/document.dart";
import "package:avert/ui/components/document.dart";
import "package:avert/ui/components/input.dart";
import "package:avert/ui/components/select.dart";
import "package:avert/ui/core.dart";
import "package:avert/utils/common.dart";
import "package:avert/utils/logger.dart";
import "package:avert/utils/ui.dart";
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
  late final AvertSelectController<Account> accountController;

  final Map<String, TextEditingController> controllers = {
    "desc": TextEditingController(),
    "debit": TextEditingController(text: "0"),
    "credit": TextEditingController(text: "0"),
  };

  @override
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  String? errMsg;

  @override
  bool isDirty = false;

  @override
  void initState() {
    super.initState();
    accountController = AvertSelectController<Account>();
  }

  @override
  void dispose() {
    super.dispose();
    for (TextEditingController controller in controllers.values) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = FTheme.of(context);
    final TextStyle selectValueStyle = theme.textFieldStyle.disabledStyle.labelTextStyle;
    final List<Widget> contents = [
      AvertSelect<Account>(
        required: true,
        label: "Account",
        valueBuilder: (context, account) {
          return (account != null)
          ? Text(account.name)
          : Text("None", style: selectValueStyle);
        },
        tileSelectBuilder: (context, value) => AvertSelectTile<Account>(
          selected: accountController.value == value,
          value: value,
          prefix: FIcon(FAssets.icons.fileType),
          title: Text(value.name, style: theme.typography.base),
          subtitle: Text(value.type.toString(), style: theme.typography.sm),
        ),
        options: widget.accounts,
        controller: accountController,
      ),
      AvertInput.multiline(
        minLines: 2,
        label: "Description",
        controller: controllers["desc"]!,
      ),
      AvertInput.number(
        autovalidateMode: AutovalidateMode.always,
        validator: (value) => validateValue("credit", value, controllers),
        label: "Debit",
        controller: controllers["debit"]!,
        required: true,
        isDecimal: true,
      ),
      AvertInput.number(
        autovalidateMode: AutovalidateMode.always,
        validator: (value) => validateValue("debit", value, controllers),
        label: "Credit",
        controller: controllers["credit"]!,
        required: true,
        isDecimal: true,
      ),
    ];

    return AvertDocumentForm<AccountingEntry>.dialog(
      formKey: formKey,
      title: Text("${isNew(document) ? "New" : "Edit"} Accounting Entry"),
      isDirty: isDirty,
      contents: contents,
      actions: [
        FButton(
          prefix: FIcon(FAssets.icons.x),
          label: Text("Cancel"),
          style: theme.buttonStyles.destructive,
          onPress: () {
            document.action = DocAction.none;
            Navigator.of(context).pop<AccountingEntry>(null);
          }
        ),
        SizedBox(
          child: FButton(
            prefix: FIcon(FAssets.icons.plus),
            label: Text("Add"),
            style: theme.buttonStyles.primary,
            onPress: submitDocument,
          ),
        ),
      ]
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

    // FocusScope.of(context).requestFocus(FocusNode());
    document.account = accountController.value!;
    document.description = controllers["desc"]?.value.text ?? "";
    document.debit = double.parse(controllers["debit"]?.value.text ?? "0");
    document.credit = double.parse(controllers["credit"]?.value.text ?? "0");

    document.action = DocAction.insert;
    Navigator.of(context).pop<AccountingEntry>(document);
  }
}

class AccountingEntryView extends StatefulWidget {
  const AccountingEntryView({
    super.key,
    required this.document,
    required this.accounts,
  });

  final AccountingEntry document;
  final List<Account> accounts;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<AccountingEntryView> implements DocumentView<AccountingEntry>{

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final AvertSelectController<Account> accountSelectController;
  late final Map<String, TextEditingController> controllers = {
    "desc": TextEditingController(),
    "debit": TextEditingController(text: document.debit.toString()),
    "credit": TextEditingController(text: document.credit.toString()),
  };

  bool isDirty = false;

  @override
  late AccountingEntry document = widget.document;

  @override
  void initState() {
    super.initState();
    accountSelectController = AvertSelectController<Account>(
      value: widget.document.account
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (TextEditingController controller in controllers.values) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = FTheme.of(context);
    final TextStyle selectValueStyle = theme.textFieldStyle.disabledStyle.labelTextStyle;
    final List<Widget> contents = [
      AvertSelect<Account>(
        required: true,
        label: "Account",
        valueBuilder: (context, account) {
          return (account != null)
          ? Text(account.name)
          : Text("None", style: selectValueStyle);
        },
        tileSelectBuilder: (context, value) => AvertSelectTile<Account>(
          selected: accountSelectController.value == value,
          value: value,
          prefix: FIcon(FAssets.icons.fileType),
          title: Text(value.name, style: theme.typography.base),
          subtitle: Text(value.type.toString(), style: theme.typography.sm),
        ),
        options: widget.accounts,
        controller: accountSelectController
      ),
      AvertInput.multiline(
        minLines: 2,
        label: "Description",
        controller: controllers["desc"]!,
      ),
      AvertInput.number(
        autovalidateMode: AutovalidateMode.always,
        validator: (value) => validateValue("credit", value, controllers),
        label: "Debit",
        controller: controllers["debit"]!,
        required: true,
        isDecimal: true,
      ),
      AvertInput.number(
        autovalidateMode: AutovalidateMode.always,
        validator: (value) => validateValue("debit", value, controllers),
        label: "Credit",
        controller: controllers["credit"]!,
        required: true,
        isDecimal: true,
      ),
    ];

    return AvertDocumentForm<AccountingEntry>.dialog(
      formKey: formKey,
      title: Text("${isNew(document) ? "New" : "Edit"} Accounting Entry"),
      isDirty: isDirty,
      contents: contents,
      actions: [
        FButton(
          prefix: FIcon(FAssets.icons.x),
          label: Text("Delete"),
          style: theme.buttonStyles.destructive,
          onPress: deleteDocument,
        ),
        SizedBox(
          child: FButton(
            prefix: FIcon(FAssets.icons.save),
            label: Text("Update"),
            style: theme.buttonStyles.primary,
            onPress: editDocument,
          ),
        ),
      ]
    );
  }

  @override
  Future<void> deleteDocument() async {
    final bool shouldDelete = await confirmDelete() ?? false;

    if (shouldDelete) {
      printWarn("Deleting Account:${document.name} with id of: ${widget.document.id}");
      document.action = DocAction.delete;
      if (mounted) Navigator.of(context).pop<AccountingEntry>(document);
    }
  }

  @override
  void editDocument() async {
    document.action = DocAction.update;
    Navigator.of(context).pop<AccountingEntry>(document);
  }

  Future<bool?> confirmDelete() async {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (BuildContext context) => FDialog(
        direction: Axis.horizontal,
        title: Text("Delete Accounting Entry?"),
        body: const Text("Are you sure you want to delete this entry?"),
        actions: <Widget>[
          FButton(
            label: const Text("No"),
            style: FButtonStyle.outline,
            onPress: () {
              Navigator.of(context).pop(false);
            },
          ),
          FButton(
            style: FButtonStyle.destructive,
            label: const Text("Yes"),
            onPress: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }
}

String? validateValue(String name, String? value, Map<String, TextEditingController> controllers) {
  if (value == null || value == "0")  return null;
  final String otherValue = controllers[name]?.value.text ?? "";
  if (otherValue == "0"|| otherValue == "") return null;
  return "Can't have value greater than 0 on both Debit and Credit";
}
