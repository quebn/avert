import "package:avert/docs/accounting/account.dart";
import "package:avert/docs/accounting/accounting_entry.dart";
import "package:avert/docs/accounting/journal_entry.dart";
import "package:avert/docs/document.dart";
import "package:avert/docs/profile.dart";
import "package:avert/ui/accounting_entry.dart";

import "package:avert/ui/components/document.dart";
import "package:avert/ui/components/date_picker.dart";
import "package:avert/ui/components/input.dart";
import "package:avert/ui/components/list_field.dart";
import "package:avert/ui/components/select.dart";
import "package:avert/ui/components/time_picker.dart";
import "package:avert/ui/core.dart";

import "package:avert/utils/common.dart";
import "package:avert/utils/database.dart";
import "package:avert/utils/logger.dart";

import "package:flutter/material.dart";
import "package:forui/forui.dart";

class JournalEntryForm extends StatefulWidget {
  const JournalEntryForm({
    super.key,
    required this.document,
    required this.onSubmit,
  });

  final JournalEntry document;
  final Future<bool> Function(JournalEntry) onSubmit;

  @override
  State<StatefulWidget> createState() => _FormState();
}

class _FormState extends State<JournalEntryForm> with TickerProviderStateMixin implements DocumentForm {

  JournalEntry get document => widget.document;
  late final FDateFieldController dateController;
  late final FTimeFieldController timeController;
  late final AvertSelectController accountController;
  late final AvertListFieldController<AccountingEntry> aeController;
  List<Account> accounts = [];

  @override
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {
    "name": TextEditingController(),
    "note": TextEditingController(),
  };

  @override
  String? errMsg;

  @override
  bool isDirty = false;

  @override
  void initState() {
    super.initState();
    final DateTime c = document.postedAt;
    dateController = FDateFieldController(vsync: this, initialDate: c);
    timeController = FTimeFieldController(vsync: this, initialTime: FTime(c.hour, c.minute));
    aeController = AvertListFieldController<AccountingEntry>(values:[]);
    fetchAccounts(widget.document.profile).then((result) {
      if (result.isNotEmpty) accounts = result;
    });
  }

  @override
  void dispose() {
    super.dispose();
    dateController.dispose();
    timeController.dispose();
    for (TextEditingController controller in controllers.values) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = FTheme.of(context);
    final FButtonStyle buttonStyle = theme.buttonStyles.primary;
    return AvertDocumentForm(
      formKey: formKey,
      title: Text("${isNew(document) ? "New" : "Edit"} Journal Entry",),
      isDirty: isDirty,
      resizeToAvoidBottomInset: false,
      floatingActionButton: !isDirty ? null : FButton.icon(
        style: theme.buttonStyles.primary.copyWith(
          enabledBoxDecoration: buttonStyle.enabledBoxDecoration.copyWith(
            borderRadius: BorderRadius.circular(33),
          )
        ),
        onPress: submitDocument,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: FIcon(FAssets.icons.save,
            size: 32,
          ),
        )
      ),
      contents: [
        AvertInput.text(
          label: "Name",
          hint: "Ex. Payment of Supplies",
          controller: controllers["name"]!,
          required: true,
          forceErrMsg: errMsg,
          initialValue: document.name,
          onChange: (value) => onValueChange(() {
            return value != document.name;
          }),
        ),
        Row(
          spacing: 8,
          children: [
            Flexible(flex: 3, child: AvertDatePicker(
              required: true,
              controller: dateController,
              onChange: (dt) => onValueChange(() {
                if (dt == null) return false;
                final DateTime pa = document.postedAt;
                return (
                  dt.year != pa.year ||
                  dt.month != pa.month ||
                  dt.day != pa.day
                );
              }),
              label: "Posting Date",
            )),
            Expanded(flex: 2, child: AvertTimePicker(
              required: true,
              controller: timeController,
              label: "Posting Time",
              onChange: (time) => onValueChange(() {
                if (time == null) return false;
                final DateTime pa = document.postedAt;
                return (
                  time.hour != pa.hour ||
                  time.minute != pa.minute
                );
              }),
            )),
          ],
        ),
        AvertInput.multiline(
          label: "Notes",
          controller: controllers["note"]!,
          hint: "Purpose of transaction...",
          onChange: (value) => onValueChange(() {
            return value != document.note;
          }),
        ),
        AvertListField<AccountingEntry>(
          controller: aeController,
          label: "Accounting Entries",
          validator: validateEntries,
          initialValues: aeController.values,
          description: JournalEntryTotal(
            controller: aeController,
            updateState: true,
            builder: (context, values) => [
              Text("Total Balance:", style: context.theme.typography.sm,),
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  getAccountingEntriesDiff(values).toString(),
                  style: context.theme.typography.base.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                ),
              ),
            ],
          ),
          tileBuilder: (context, value, index) {
            value.name = (index + 1).toString();
            return AccountingEntryTile(
              key: ObjectKey(value),
              onDelete: () => aeController.remove(value),
              document: value,
              accounts: accounts,
            );
          },
          required: true,
          list: document.entries,
          onChange: (value) => onValueChange(() {
            return !document.entries.contains(value);
          }),
          addDialogFormBuilder: (context, index) => AccountingEntryForm(
            document: AccountingEntry(
              name: index,
              journalEntry: document,
              type: EntryType.none,
              createdAt: DateTime.now().millisecondsSinceEpoch
            ),
            accounts: accounts,
            index: index,
          ),
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
    printInfo("Pressed Submit Button");
    if (!isValid) return;
    FocusScope.of(context).requestFocus(FocusNode());

    document.name = controllers["name"]!.value.text;
    document.note = controllers["note"]!.value.text;
    document.postedAt = dateController.value!.copyWith(
      hour: timeController.value!.hour,
      minute: timeController.value!.minute,
    );

    final bool success = await widget.onSubmit(document);
    if (!success) return;
    final List<AccountingEntry> failed = await insertDocuments<AccountingEntry>(aeController.values);
    if (failed.isEmpty && mounted) Navigator.of(context).pop<JournalEntry>(document);
  }

  String? validateEntries(List<AccountingEntry>? entries) {
    if (entries == null) return "Debit and Credit entries should be present";
    final double diff = getAccountingEntriesDiff(entries);
    if (diff == 0) return null;
    return "Debit and Credit in Accounting Entries should be balance";
  }
}

class JournalEntryTotal extends StatefulWidget {
  const JournalEntryTotal({
    super.key,
    required this.controller,
    required this.builder,
    required this.updateState,
  });

  final AvertListFieldController<AccountingEntry> controller;
  final List<Widget> Function(BuildContext, List<AccountingEntry>) builder;
  final bool updateState;

  @override
  State<StatefulWidget> createState() => _TotalState();
}

class _TotalState extends State<JournalEntryTotal> {
  int updateCount = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addValueListener(updateState);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeValueListener(updateState);
  }

  void updateState(List<AccountingEntry> values, AccountingEntry value) {
    final bool shouldUpdate = widget.updateState;
    if (!shouldUpdate) return;
    setState(() => updateCount++);
  }

  @override
  Widget build(BuildContext context) => Row(
    children: widget.builder(context, widget.controller.values),
  );
}

class JournalEntryTile extends StatefulWidget {
  const JournalEntryTile({super.key,
    required this.document,
    required this.profile,
    required this.removeDocument,
  });

  final JournalEntry document;
  final Profile profile;
  final void Function(JournalEntry) removeDocument;

  @override
  State<StatefulWidget> createState() => _TileState();
}

class _TileState extends State<JournalEntryTile> {
  late String name = widget.document.name;

  @override
  Widget build(BuildContext context) {
    printTrack("build account tile with name of :${widget.document.name}");
    final FThemeData theme = FTheme.of(context);
    return ListTile(
      title: Text(name, style: theme.typography.base),
      onTap: viewAccount,
    );
  }

  void viewAccount() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Container(
          // document: widget.document,
        ),
      )
    );

    if (widget.document.action == DocAction.none) return;

    switch (widget.document.action) {
      case DocAction.update: {
        setState(() => name = widget.document.name);
      } break;
      case DocAction.delete: {
        widget.removeDocument(widget.document);
      } break;
      default: break;
    }
  }
}
