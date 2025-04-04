import "package:avert/docs/accounting/journal_entry.dart";
import "package:avert/docs/core.dart";
import "package:avert/docs/profile.dart";

import "package:avert/ui/components/document.dart";
import "package:avert/ui/components/dt_picker.dart";
import "package:avert/ui/components/input.dart";
import "package:avert/ui/core.dart";

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

class _FormState extends State<JournalEntryForm> with SingleTickerProviderStateMixin implements DocumentForm {

  JournalEntry get document => widget.document;
  late final FDateFieldController dtController;

  @override
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  final Map<String, TextEditingController> controllers = {
    'name': TextEditingController(),
  };

  @override
  String? errMsg;

  @override
  bool isDirty = false;

  @override
  void initState() {
    super.initState();
    dtController = FDateFieldController(vsync: this, initialDate: document.postedAt);
  }

  @override
  void dispose() {
    super.dispose();
    dtController.dispose();
    for (TextEditingController controller in controllers.values) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AvertDocumentForm(
      title: Text("${isNew(document) ? "New" : "Edit"} Journal Entry",),
      contents: [
        AvertInput.text(
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
        AvertDTPicker(
          controller: dtController,
          label: "Posting Date",
        ),
        // TODO: date time picker
        // Time Picker for Posting Time.
        // TODO: list
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
    document.postedAt = dtController.value;
    // TODO: date
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
      // leading: FIcon(_icon),
      // subtitle: Text(_root, style: theme.typography.sm),
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
