import "package:avert/docs/accounting/accounting_entry.dart";
import "package:avert/docs/accounting/journal_entry.dart";
import "package:avert/docs/document.dart";
import "package:avert/docs/profile.dart";

import "package:avert/ui/components/document.dart";
import "package:avert/ui/components/date_picker.dart";
import "package:avert/ui/components/input.dart";
import "package:avert/ui/components/list_field.dart";
import "package:avert/ui/components/time_picker.dart";
import "package:avert/ui/core.dart";
import "package:avert/ui/module.dart";

import "package:avert/utils/common.dart";
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

  @override
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  final Map<String, TextEditingController> controllers = {
    'name': TextEditingController(),
    'note': TextEditingController(),
  };

  @override
  String? errMsg;

  @override
  bool isDirty = false;

  @override
  void initState() {
    super.initState();
    final DateTime c = document.postedAt ?? DateTime.now();
    dateController = FDateFieldController(vsync: this, initialDate: c);
    timeController = FTimeFieldController(vsync: this, initialTime: FTime(c.hour, c.minute));
  }

  @override
  void dispose() {
    super.dispose();
    dateController.dispose();
    for (TextEditingController controller in controllers.values) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AvertDocumentForm(
      title: Text("${isNew(document) ? "New" : "Edit"} Journal Entry",),
      isDirty: isDirty,
      floatingActionButton: !isDirty ? null : IconButton.filled(
        onPressed: submitDocument,
        iconSize: 48,
        icon: Icon(Icons.save_rounded)
      ),
      contents: [
        AvertInput.text(
          yMargin: 8,
          label: "Name",
          hint: "Ex. Payment of Supplies",
          controller: controllers['name']!,
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
            Flexible(
              flex: 1,
              child: AvertDatePicker(
                required: true,
                controller: dateController,
                label: "Posting Date",
              ),
            ),
            Expanded(
              child: AvertTimePicker(
                required: true,
                controller: timeController,
                label: "Posting Time",
              ),
            ),
          ],
        ),
        AvertInput.multiline(
          yMargin: 8,
          label: "Notes",
          controller: controllers['note']!,
          hint: "Purpose of transaction...",
        ),
        AvertListField<AccountingEntry>(
          label: "Accounting Entries",
          tileBuilder: (context, val) => ListTile(),
          required: true,
          list: [],
        ),
        // TODO: implement list_field
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

    document.name = controllers['name']!.value.text;
    document.postedAt = dateController.value!.copyWith(
      hour: timeController.value!.hour,
      minute: timeController.value!.minute,
    );
    document.note = controllers['note']!.value.text;
    // TODO: entries

    final bool success = await widget.onSubmit(document);
    if (success && mounted) Navigator.of(context).pop<JournalEntry>(document);
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
  late String _name = widget.document.name;
  // late String _root = widget.document.root.toString();
  // late SvgAsset _icon = widget.document.isGroup ? FAssets.icons.folder : FAssets.icons.file;

  @override
  Widget build(BuildContext context) {
    printTrack("build account tile with name of :${widget.document.name}");
    final FThemeData theme = FTheme.of(context);
    return ListTile(
      title: Text(_name, style: theme.typography.base),
      onTap: _viewAccount,
    );
  }

  void _viewAccount() async {
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
        setState(() => _name = widget.document.name);
      } break;
      case DocAction.delete: {
        widget.removeDocument(widget.document);
      } break;
      default: break;
    }
  }
}
