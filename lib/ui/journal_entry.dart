import "package:avert/docs/accounting.dart";
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
import "package:avert/utils/ui.dart";

import "package:flutter/material.dart";
import "package:forui/forui.dart";

class JournalEntryForm extends StatefulWidget {
  const JournalEntryForm({
    super.key,
    required this.document,
    required this.onSubmit,
  });

  final JournalEntry document;
  final Future<bool> Function() onSubmit;

  @override
  State<StatefulWidget> createState() => _FormState();
}

class _FormState extends State<JournalEntryForm> with TickerProviderStateMixin implements DocumentForm {

  // TODO: add some sort of variable where e
  JournalEntry get document => widget.document;
  late final FDateFieldController dateController;
  late final FTimeFieldController timeController;
  late final AvertSelectController<Account> accountController;
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
    aeController = AvertListFieldController<AccountingEntry>(values:document.entries);
    final Profile profile = document.profile;
    fetchAccounts(
      profile,
      where: "profile_id = ? and is_group = ?",
      whereArgs: [profile.id, 0]).then((result) {
        if (result.isNotEmpty && mounted) setState(() => accounts = result);
      }
    );
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
          onChange: (value) => onValueChange(setState, this, () {
            return value != document.name;
          }),
        ),
        Row(
          spacing: 8,
          children: [
            Flexible(flex: 3, child: AvertDatePicker(
              required: true,
              controller: dateController,
              onChange: (dt) => onValueChange(setState, this, () {
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
              onChange: (time) => onValueChange(setState, this, () {
                if (time == null) return false;
                final DateTime pa = document.postedAt;
                return ( time.hour != pa.hour || time.minute != pa.minute);
              }),
            )),
          ],
        ),
        AvertInput.multiline(
          label: "Notes",
          controller: controllers["note"]!,
          hint: "Purpose of transaction...",
          onChange: (value) => onValueChange(setState, this, () {
            return value != document.note;
          }),
        ),
        AvertListField<AccountingEntry>(
          controller: aeController,
          label: "Accounting Entries",
          validator: validateEntries,
          initialValues: aeController.values,
          required: true,
          list: document.entries,
          onNewItem: newEntryItem,
          onChange: (value) => onValueChange(setState, this, () {
            if (value.action == DocAction.update) return true;
            return true;
          }),
          tileBuilder: (context, doc, index) {
            doc.name = index.toString();
            return AccountingEntryTile(
              key: ObjectKey(doc),
              index: index+1,
              document: doc,
              accounts: accounts,
              onChange: () => onValueChange(setState, this, () {
                return true;
              }),
              onRemove: () => aeController.remove(doc, hardRemove: isNew(doc)),
            );
          },
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
        ),
      ],
    );
  }

  void newEntryItem() async {
    final int index = aeController.values.length + 1;
    final AccountingEntry entry = AccountingEntry(
      journalEntry: document,
      type: EntryType.none,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    final bool? success = await showAdaptiveDialog(
      context: context,
      builder: (context) => AccountingEntryForm.add(
        document: entry,
        accounts: accounts,
        title: "New Accounting Entry #$index",
      ),
    );
    if (success == null || !success || entry.action != DocAction.insert) return;
    aeController.add(entry);
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
    document.entries = aeController.valuesWithCachedRemoved;
    final bool success = await widget.onSubmit();

    if (success && mounted) {
      Navigator.of(context).pop<bool>(true);
    }
  }

  String? validateEntries(List<AccountingEntry>? entries) {
    if (entries == null) return "Debit and Credit entries should be present";
    final AccountValue diff = getAccountingEntriesDiff(entries);
    if (diff.amount == 0) return null;
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

class JournalEntryView extends StatefulWidget {
  const JournalEntryView({ super.key,
    required this.document,
  });

  final JournalEntry document;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<JournalEntryView> with TickerProviderStateMixin implements DocumentView<JournalEntry>  {
  int updateCount = 0;
  late final FPopoverController controller;
  List<Widget> entries = [];

  @override
  JournalEntry get document => widget.document;

  @override
  void initState() {
    super.initState();
    controller = FPopoverController(vsync: this);
    document.fetchEntries().then((_) {
      setState(() => updateCount++);
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building Account Document View");
    final FThemeData theme = FTheme.of(context);
    final FCardContentStyle contentStyle = theme.cardStyle.contentStyle;

    buildEntryWidgets();
    final List<Widget> header = [
      Row (
        children: [
          FIcon(FAssets.icons.file, size: 48),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(document.name, style: contentStyle.titleTextStyle),
              Text(formatDT(document.postedAt), style: contentStyle.subtitleTextStyle),
            ],
          ),
        ],
      ),
      SizedBox(height: 8),
      Text( document.note, style: theme.typography.base),
      SizedBox(height: 4),
    ];
    return AvertDocumentView<JournalEntry>(
      controller: controller,
      name: "Journal Entry",
      header: header,
      editDocument: editDocument,
      deleteDocument: deleteDocument,
      content: Column(
        children: [
          Text("Accounting Entries", style: theme.textFieldStyle.enabledStyle.labelTextStyle),
          SizedBox(
            child: entries.isNotEmpty ? Column(
              children: entries
            ): Text("No Entries", style: theme.typography.sm),
          )
        ]
      ),
    );
  }

  @override
  void editDocument() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => JournalEntryForm(
        document: document,
        onSubmit: onEdit,
      ),
    ));
    if (document.action == DocAction.none) return;
    if (document.action == DocAction.update) {
      // printInfo("entries");
      setState(() => updateCount++);
    }
  }

  Future<bool> onEdit() async  {
    final String? error = await document.update();
    String msg = error ?? "Journal Entry updated!";
    if (mounted) notify(context, msg);
    return error == null;
  }

  Future<bool?> confirmDelete() {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (BuildContext context) => FDialog(
        direction: Axis.horizontal,
        title: Text("Delete '${document.name}'?"),
        body: const Text("Are you sure you want to delete this Journal Entry?"),
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

  @override
  Future<void> deleteDocument() async {
    final bool shouldDelete = await confirmDelete() ?? false;

    if (shouldDelete) {
      final String? error = await document.delete();

      if (error != null) {
        if (mounted) notify(context, error);
        return;
      }
      printWarn("Deleting Journal Entry:${document.name} with id of: ${widget.document.id}");
      if (mounted) Navigator.of(context).pop();
    }
  }

  void buildEntryWidgets() {
    printInfo("Building Entries");
    List<Widget> list = [];
    int index = 0;
    for (AccountingEntry entry in document.entries) {
      list.add(entryTileBuilder(entry, index++));
    }
    entries = list;
  }

  Widget entryTileBuilder(AccountingEntry entry, int index) {
    printTrack("Building Entry Tile with index of: ${entry.name}");
    final FThemeData theme = FTheme.of(context);
    final FBadgeStyle badgeStyle = entry.value.type == EntryType.debit ? theme.badgeStyles.primary.copyWith(
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
      onPress: null,
      value: entry,
      // TODO: format to currency formatting with monofonts
      details: Text(
        entry.value.toString(),
        style: theme.typography.base.copyWith(
          fontWeight: FontWeight.bold
        ),
      ),
      suffix: FBadge(
        label: Text(entry.value.type.abbrev),
        style: badgeStyle,
      ),
      title: Text("${index+1}. ${entry.account!.name}"),
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
  int updateCount = 0;
  JournalEntry get document => widget.document;

  @override
  Widget build(BuildContext context) {
    // document.fetchEntries();
    printTrack("build journal entry tile with name of :${widget.document.name}");
    final FThemeData theme = FTheme.of(context);
    return ListTile(
      leading: FIcon(FAssets.icons.file),
      title: Text(document.name, style: theme.typography.base.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(formatDT(document.postedAt), style: theme.typography.sm),
      onTap: view,
    );
  }

  void view() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
        JournalEntryView(
          document: document,
          // document: widget.document,
        ),
      )
    );

    if (widget.document.action == DocAction.none) return;

    switch (widget.document.action) {
      case DocAction.update: {
        setState(() => updateCount++);
      } break;
      case DocAction.delete: {
        widget.removeDocument(widget.document);
      } break;
      default: break;
    }
  }
}
