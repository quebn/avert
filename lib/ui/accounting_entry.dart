import "package:avert/docs/accounting/account.dart";
import "package:avert/docs/accounting/accounting_entry.dart";
import "package:avert/docs/document.dart";
import "package:avert/ui/components/document.dart";
import "package:avert/ui/components/input.dart";
import "package:avert/ui/components/list_field.dart";
import "package:avert/ui/components/select.dart";
import "package:avert/ui/core.dart";
import "package:avert/utils/logger.dart";
import "package:flutter/material.dart";

import "package:forui/forui.dart";

class AccountingEntryForm extends StatefulWidget {
  const AccountingEntryForm({
    super.key,
    required this.document,
    required this.accounts,
    required this.index
  });

  final AccountingEntry document;
  final List<Account> accounts;
  final int index;

  @override
  State<StatefulWidget> createState() => _FormState();
}

class _FormState extends State<AccountingEntryForm> implements DocumentForm {

  AccountingEntry get document => widget.document;
  late final AvertSelectController<Account> accountController;
  late final AvertSelectController<EntryType> typeController;
  late final Map<String, TextEditingController> controllers = {
    "desc": TextEditingController(),
    "value": TextEditingController(text: widget.document.value.toString()),
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
    typeController = AvertSelectController<EntryType>(
      value: document.type,
    );
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
          prefix: FIcon(
            value.isGroup ? FAssets.icons.folder : FAssets.icons.file
          ),
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
      AvertSelect<EntryType>(
        options: const [EntryType.debit, EntryType.credit],
        label: "Entry Type",
        prefix: FIcon(FAssets.icons.type),
        required: true,
        validator: validateType,
        valueBuilder: (context, type) => Text(type.toString()),
        controller: typeController,
        tileSelectBuilder: (context, value) => AvertSelectTile<EntryType>(
          selected: typeController.value == value,
          value: value,
          prefix: FIcon(FAssets.icons.folderRoot),
          title: Text(value.toString(), style: theme.typography.base),
        ),
      ),
      AvertInput.number(
        // autovalidateMode: AutovalidateMode.always,
        validator: validateValue,
        label: "Value",
        controller: controllers["value"]!,
        required: true,
        isDecimal: true,
      ),
    ];

    return AvertDocumentForm<AccountingEntry>.dialog(
      formKey: formKey,
      title: Text("New Accounting Entry #${widget.index}"),
      isDirty: isDirty,
      contents: contents,
      actions: [
        FButton(
          prefix: FIcon(FAssets.icons.x),
          label: const Text("Cancel"),
          style: theme.buttonStyles.destructive,
          onPress: () {
            document.action = DocAction.none;
            Navigator.of(context).pop<AccountingEntry>(null);
          }
        ),
        SizedBox(
          child: FButton(
            prefix: FIcon(FAssets.icons.plus),
            label: const Text("Add"),
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
    document.type = typeController.value!;
    document.value = double.parse(controllers["value"]?.value.text ?? "0");

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
  late final AvertSelectController<Account> accountController;
  late final AvertSelectController<EntryType> typeController;
  late final Map<String, TextEditingController> controllers = {
    "desc": TextEditingController(text: document.description),
    "value": TextEditingController(text: document.value.toString()),
  };

  bool isDirty = false;

  @override
  late AccountingEntry document = widget.document;

  @override
  void initState() {
    super.initState();
    typeController = AvertSelectController<EntryType>(
      value: document.type,
    );
    accountController = AvertSelectController<Account>(
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
        label: "value",
        valueBuilder: (context, account) {
          return (account != null)
          ? Text(account.name)
          : Text("None", style: selectValueStyle);
        },
        tileSelectBuilder: (context, value) => AvertSelectTile<Account>(
          selected: accountController.value == value,
          value: value,
          prefix: FIcon(
            value.isGroup ? FAssets.icons.folder : FAssets.icons.file
          ),
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
      AvertSelect<EntryType>(
        options: const [EntryType.debit, EntryType.credit],
        label: "Entry Type",
        prefix: FIcon(FAssets.icons.type),
        required: true,
        valueBuilder: (context, type) => Text(type.toString()),
        controller: typeController,
        validator: validateType,
        tileSelectBuilder: (context, value) => AvertSelectTile<EntryType>(
          selected: typeController.value == value,
          value: value,
          prefix: FIcon(FAssets.icons.folderRoot),
          title: Text(value.toString(), style: theme.typography.base),
        ),
      ),
      AvertInput.number(
        validator: validateValue,
        label: "Value",
        controller: controllers["value"]!,
        required: true,
        isDecimal: true,
      ),
    ];

    return AvertDocumentForm<AccountingEntry>.dialog(
      formKey: formKey,
      title: Text("Edit Accounting Entry ${document.name}"),
      isDirty: isDirty,
      contents: contents,
      actions: [
        FButton(
          prefix: FIcon(FAssets.icons.x),
          label: const Text("Delete"),
          style: theme.buttonStyles.destructive,
          onPress: deleteDocument,
        ),
        SizedBox(
          child: FButton(
            prefix: FIcon(FAssets.icons.save),
            label: const Text("Update"),
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
    final bool isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    document.action = DocAction.update;
    document.account =  accountController.value;
    document.description = controllers["desc"]!.value.text;
    
    document.value = double.parse(controllers["value"]!.value.text);

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

String? validateType(EntryType? type) {
  if (type != EntryType.none) return null;
  return "Should be 'Debit' or 'Credit'";
}

String? validateValue(String? value) {
  double thisValue = double.parse(value ?? "0.0");
  if (thisValue == 0) return "Field value should be non-zero";
  return null;
}

class AccountingEntryTile extends StatefulWidget {
  const AccountingEntryTile({
    super.key,
    required this.document,
    required this.accounts,
    this.onDelete,
    this.onUpdate,
  });

  final AccountingEntry document;
  final List<Account> accounts;
  final Function()? onDelete;
  final Function()? onUpdate;

  @override
  State<StatefulWidget> createState() => _TileState();
}

class _TileState extends State<AccountingEntryTile> {
  late AccountingEntry document = widget.document;
  int updateCount = 0;

  @override
  Widget build(BuildContext context) {
    printTrack("Building Accounting Entry tile with index of: ${document.name}");
    final FThemeData theme = FTheme.of(context);
    final FBadgeStyle badgeStyle = document.type == EntryType.debit ? theme.badgeStyles.primary.copyWith(
      backgroundColor: Colors.teal,
      borderColor: Colors.teal,
      contentStyle: theme.badgeStyles.primary.contentStyle.copyWith(
        labelTextStyle: theme.badgeStyles.primary.contentStyle.labelTextStyle.copyWith(
          color: theme.colorScheme.foreground
        ),
      ),
    ):theme.badgeStyles.destructive;

    return AvertListFieldTile<AccountingEntry>(
      key: widget.key,
      onPress: onPress,
      value: document,
      // TODO: format to currency formatting with monofonts
      details: Text(
        document.value.toString(),
        style: theme.typography.base.copyWith(
          fontWeight: FontWeight.bold
        ),
      ),
      suffix: FBadge(
        label: Text(document.type.abbrev),
        style: badgeStyle,
      ),
      title: Text("${document.name}. ${document.account!.name}"),
    );
  }

  void onPress() async {
    AccountingEntry? doc = await showAdaptiveDialog(
      context: context,
      builder: (context) => AccountingEntryView(
        document: document,
        accounts: widget.accounts,
      ),
    );
    if (doc == null) return;
    switch(doc.action) {
      case DocAction.delete: {
        widget.onDelete?.call();
      } break;
      case DocAction.update: {
        widget.onUpdate?.call();
        setState(() => updateCount++);
      } break;
      default:return;
    }
  }
}
