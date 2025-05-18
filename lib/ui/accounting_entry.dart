import "package:avert/docs/accounting.dart";
import "package:avert/docs/document.dart";
import "package:avert/ui/components/document.dart";
import "package:avert/ui/components/input.dart";
import "package:avert/ui/components/list_field.dart";
import "package:avert/ui/components/select.dart";
import "package:avert/ui/core.dart";
import "package:avert/utils/common.dart";
import "package:avert/utils/logger.dart";
import "package:avert/utils/ui.dart";
import "package:flutter/material.dart";

import "package:forui/forui.dart";

class AccountingEntryForm extends StatefulWidget {
  const AccountingEntryForm({
    super.key,
    required this.document,
    required this.accounts,
    required this.title,
    required this.isAdd,
    required this.onSubmit,
  });

  const AccountingEntryForm.update({
    super.key,
    required this.document,
    required this.accounts,
    required this.title,
    required this.onSubmit,
  }): isAdd = false;

  const AccountingEntryForm.add({
    super.key,
    required this.document,
    required this.accounts,
    required this.title,
    required this.onSubmit,
  }): isAdd = true;

  final AccountingEntry document;
  final List<Account> accounts;
  final Future<bool> Function(AccountingEntry)? onSubmit;
  final String title;
  final bool isAdd;

  @override
  State<StatefulWidget> createState() => _NewFormState();
}

class _NewFormState extends State<AccountingEntryForm> implements DocumentForm {
  bool get isAdd => widget.isAdd;

  AccountingEntry get document => widget.document;
  late final AvertSelectController<Account> accountController;
  late final AvertSelectController<EntryType> typeController;
  late final Map<String, TextEditingController> controllers = {
    "desc": TextEditingController(text: document.description),
    "value": TextEditingController(text: document.value.amount.toString()),
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
      value: document.value.type,
    );
    accountController = AvertSelectController<Account>(
      value: widget.document.account,
      onUpdate: (value, didChange) {
        if (didChange) {
          final EntryType type = value?.positive ?? EntryType.none;
          if (typeController.value != type) {
            setState(() => typeController.update(type));
          }
        }
      },

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
    if (widget.accounts.isEmpty) printWarn("Entry Accounts options is empty!");
    final FThemeData theme = FTheme.of(context);
    final TextStyle selectValueStyle = theme.textFieldStyle.disabledStyle.labelTextStyle;
    final List<Widget> contents = [
      AvertSelect<Account>(
        required: true,
        label: "Account",
        // onChange: onAccountChange,
        options: widget.accounts,
        controller: accountController,
        valueBuilder: (context, account) {
          return (account != null)
          ? Text(account.name)
          : Text("None", style: selectValueStyle);
        },
        tileSelectBuilder: (context, value) => AvertSelectTile<Account>(
          selected: accountController.value == value,
          value: value,
          prefix: FIcon(FAssets.icons.file),
          title: Text(value.name, style: theme.typography.base),
          subtitle: Text(value.type.toString(), style: theme.typography.sm),
        ),
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
        validator: validateValue,
        label: "Value",
        controller: controllers["value"]!,
        required: true,
        isDecimal: true,
        onTap: () => clearNumberField(controllers["value"]!),
      ),
    ];

    return AvertDocumentForm<AccountingEntry>.dialog(
      formKey: formKey,
      title: Text(widget.title),
      isDirty: isDirty,
      contents: contents,
      actions: [
        FButton(
          prefix: FIcon(FAssets.icons.x),
          label: Text(isAdd ? "Cancel" : "Remove"),
          style: theme.buttonStyles.destructive,
          onPress: closeDocument,
        ),
        SizedBox(
          child: FButton(
            prefix: FIcon(FAssets.icons.plus),
            label: Text(isAdd ? "Add" : "Update"),
            style: theme.buttonStyles.primary,
            onPress: submitDocument,
          ),
        ),
      ]
    );
  }

  @override
  void submitDocument() async {
    final bool isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    document.account = accountController.value!;
    document.description = controllers["desc"]?.value.text ?? "";
    document.value = AccountValue(
      typeController.value!,
      double.parse(controllers["value"]?.value.text ?? "0")
    );
    document.action = isNew(document) ? DocAction.insert : DocAction.update;
    final bool success = await widget.onSubmit?.call(document) ?? true;
    printInfo("Submitting Accounting Entry with success value of $success");
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop<bool>(true);
    } else {
      notify(context, "Unable to ${isAdd ? "New" : "Update"} accounting entry not enough balance");
    }
  }

  Future<bool?> confirmRemove() async {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (BuildContext context) => FDialog(
        direction: Axis.horizontal,
        title: Text("Remove Accounting Entry?"),
        body: const Text("Are you sure you want to remove this entry?"),
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

  Future<void> closeDocument() async {
    bool shouldClose = true;
    if (isAdd) {
      document.action = DocAction.none;
    } else {
      shouldClose = await confirmRemove() ?? false;
      if (shouldClose &&  !isNew(document)) {
        document.action = DocAction.delete;
      }
    }
    if (!mounted || !shouldClose) return;
    Navigator.of(context).pop<bool>(false);
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
    required this.index,
    required this.onRemove,
    required this.formBuilder,
    this.onChange,
  });

  final int index;
  final AccountingEntry document;
  final List<Account> accounts;
  final void Function()? onChange;
  final void Function()? onRemove;
  final Widget Function(BuildContext)? formBuilder;

  @override
  State<StatefulWidget> createState() => _TileState();
}

class _TileState extends State<AccountingEntryTile> {
  AccountingEntry get document => widget.document;
  int updateCount = 0;

  @override
  Widget build(BuildContext context) {
    printTrack("Building Accounting Entry tile with index of: ${document.name}");
    final FThemeData theme = FTheme.of(context);
    final FBadgeStyle badgeStyle = document.value.type == EntryType.debit ? theme.badgeStyles.primary.copyWith(
      backgroundColor: Colors.teal,
      borderColor: Colors.teal,
      contentStyle: theme.badgeStyles.primary.contentStyle.copyWith(
        labelTextStyle: theme.badgeStyles.primary.contentStyle.labelTextStyle.copyWith(
          color: theme.colorScheme.foreground
        ),
      ),
    ) : theme.badgeStyles.destructive;

    return AvertListFieldTile<AccountingEntry>(
      key: widget.key,
      onPress: widget.formBuilder == null ? null : onPress,
      value: document,
      details: Text(
        document.value.amount.toString(),
        style: theme.typography.base.copyWith(
          fontSize: theme.typography.sm.fontSize,
          fontWeight: FontWeight.bold
        ),
      ),
      suffix: FBadge(
        label: Text(document.value.type.abbrev),
        style: badgeStyle,
      ),
      title: Text("${widget.index}. ${document.account!.name}"),
    );
  }

  void onPress() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final bool? success = await showAdaptiveDialog<bool>(
      context: context,
      builder: widget.formBuilder!,
    );

    if (success == null) return;
    if (success) {
      widget.onChange?.call();
      setState(() => updateCount++);
    } else {
      widget.onRemove?.call();
    }
  }
}

void clearNumberField(TextEditingController? controller) {
  final double value = double.tryParse(controller?.value.text ?? "0") ?? 0;
  printInfo("$value -> ${controller?.value.text}");
  if (controller == null || value != 0) return;
  controller.value = TextEditingValue();
}
