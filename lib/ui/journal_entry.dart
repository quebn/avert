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
  List<Account> accounts = []; // TODO: fetch this

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
    fetchAllAccounts(widget.document.profile).then((result) {
      if (result.isNotEmpty) accounts = result;
    });
    dateController.addValueListener(checkDate);
    timeController.addValueListener(checkTime);
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
              label: "Posting Date",
            )),
            Expanded(flex: 2, child: AvertTimePicker(
              required: true,
              controller: timeController,
              label: "Posting Time",
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
          tileBuilder: (context, val) => AvertListFieldTile(
            onPress: viewAccountingEntry,
            value: val,
            title: Text(val.account!.name),
          ),
          required: true,
          list: document.entries,
          onChange: (value) => onValueChange(() {
            return !document.entries.contains(value);
          }),
          addDialogFormBuilder: (context) => AccountingEntryForm(
            document: AccountingEntry(
              journalEntry: document,
              createdAt: DateTime.now().millisecondsSinceEpoch
            ),
            accounts: accounts,
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
    if (!isValid) return;
    FocusScope.of(context).requestFocus(FocusNode());

    document.name = controllers["name"]!.value.text;
    document.postedAt = dateController.value!.copyWith(
      hour: timeController.value!.hour,
      minute: timeController.value!.minute,
    );
    document.note = controllers["note"]!.value.text;
    // TODO: iterate and insert entries.

    final bool success = await widget.onSubmit(document);
    if (success && mounted) Navigator.of(context).pop<JournalEntry>(document);
  }

  void checkDate(DateTime? dt) => onValueChange(() {
    if (dt == null) return false;
    final DateTime pa = document.postedAt;
    return dt.year != pa.year || dt.month != pa.month || dt.day != pa.day ;
  });

  void checkTime(FTime? t) => onValueChange(() {
    if (t == null) return false;
    final DateTime pa = document.postedAt;
    return t.hour != pa.hour || t.minute != pa.minute;
  });

  void viewAccountingEntry() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccountingEntryView(
          // document: widget.document,
        ),
      )
    );
  }
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
